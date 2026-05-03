#!/usr/bin/env -S falcon-host
# frozen_string_literal: true

require "falcon/environment/rack"

hostname = File.basename(__dir__)

service hostname do
	include Falcon::Environment::Rack

	# Preload the Rails application before forking workers.
	preload "preload.rb"

	# Number of worker processes (defaults to 2, configure via WEB_CONCURRENCY).
	count ENV.fetch("WEB_CONCURRENCY", 2).to_i

	# Default to port 3000 unless otherwise specified.
	port { ENV.fetch("PORT", 3000).to_i }

	# Use HTTP/1.1 for compatibility with reverse proxies and load balancers.
	endpoint do
		Async::HTTP::Endpoint
			.parse("http://0.0.0.0:#{port}")
			.with(protocol: Async::HTTP::Protocol::HTTP11)
	end
end
