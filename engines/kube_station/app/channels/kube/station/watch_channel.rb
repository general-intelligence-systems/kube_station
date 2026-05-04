require "console"
require "async/http/internet"
require "json"

module Kube
  module Station
    class WatchChannel < ActionCable::Channel::Base
      def subscribed
        Console.info(self, "subscribed called", cluster_id: params[:cluster_id])

        cluster = Cluster.find(params[:cluster_id])
        Console.info(self, "cluster found", name: cluster.name)

        @kubeconfig_file = Tempfile.new(["kubeconfig", ".yaml"])
        @kubeconfig_file.write(cluster.config.data)
        @kubeconfig_file.close

        @proxy_rd, proxy_wr = IO.pipe
        @proxy_pid = Process.spawn(
          "kubectl", "proxy", "--port=0",
          "--kubeconfig=#{@kubeconfig_file.path}",
          out: proxy_wr, err: "/dev/null"
        )
        proxy_wr.close

        banner = @proxy_rd.gets
        @proxy_port = banner[/127\.0\.0\.1:(\d+)/, 1].to_i
        Console.info(self, "proxy ready", port: @proxy_port, pid: @proxy_pid)
        @proxy_rd.close

        resources = params[:resources] || ["/v1/pods"]
        Console.info(self, "resources", resources: resources)

        @kwatch_rd, kwatch_wr = IO.pipe
        kwatch_err_rd, kwatch_err_wr = IO.pipe
        @kwatch_pid = Process.spawn(
          kwatch_binary_path,
          "-proxy", "http://127.0.0.1:#{@proxy_port}",
          *resources,
          out: kwatch_wr, err: kwatch_err_wr
        )
        kwatch_wr.close
        kwatch_err_wr.close
        Console.info(self, "kwatch spawned", pid: @kwatch_pid)

        @internet = Async::HTTP::Internet.new

        Async do
          kwatch_err_rd.each_line do |line|
            Console.info(self, "kwatch stderr", line: line.chomp)
          end
        end

        @reader_task = Async do
          Console.info(self, "reader task started")
          @kwatch_rd.each_line do |line|
            type, gvr, ns, name, rv = line.chomp.split("\t")

            if type == "DELETED"
              transmit({
                "event" => "DELETED",
                "gvr" => gvr,
                "namespace" => ns,
                "name" => name
              })
            else
              obj = fetch_object(gvr, ns, name)
              next unless obj

              transmit({
                "event" => type,
                "gvr" => gvr,
                "node" => trim(obj)
              })
            end
          end
          Console.info(self, "reader task ended")
        end
      end

      def unsubscribed
        Console.info(self, "unsubscribed called")
        @reader_task&.stop
        @internet&.close

        if @kwatch_pid
          Process.kill("TERM", @kwatch_pid) rescue nil
          Process.wait(@kwatch_pid) rescue nil
        end

        if @proxy_pid
          Process.kill("TERM", @proxy_pid) rescue nil
          Process.wait(@proxy_pid) rescue nil
        end

        @kwatch_rd&.close rescue nil
        @kubeconfig_file&.unlink rescue nil
      end

      private

      def fetch_object(gvr, ns, name)
        group, version, resource = gvr.split("/", 3)
        path = if group.empty?
          ns.empty? ? "/api/#{version}/#{resource}/#{name}" : "/api/#{version}/namespaces/#{ns}/#{resource}/#{name}"
        elsif ns.empty?
          "/apis/#{group}/#{version}/#{resource}/#{name}"
        else
          "/apis/#{group}/#{version}/namespaces/#{ns}/#{resource}/#{name}"
        end

        url = "http://127.0.0.1:#{@proxy_port}#{path}"
        response = @internet.get(url)

        if response.status == 200
          JSON.parse(response.read)
        else
          Console.warn(self, "fetch failed", path: path, status: response.status)
          response.close
          nil
        end
      rescue => e
        Console.warn(self, "fetch error", error: e.message)
        nil
      end

      def trim(obj)
        meta = obj["metadata"] || {}
        {
          "uid" => meta["uid"],
          "name" => meta["name"],
          "namespace" => meta["namespace"],
          "kind" => obj["kind"],
          "apiVersion" => obj["apiVersion"],
          "labels" => meta["labels"],
          "creationTimestamp" => meta["creationTimestamp"],
          "ownerReferences" => meta["ownerReferences"]
        }
      end

      def kwatch_binary_path
        Engine.root.join("bin", "kwatch", "kwatch").to_s
      end
    end
  end
end
