package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/cache"
	toolswatch "k8s.io/client-go/tools/watch"
)

func main() {
	proxyURL := flag.String("proxy", "http://127.0.0.1:8001", "kubectl proxy URL")
	flag.Parse()

	args := flag.Args()
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, "kwatch: no resources specified (format: group/version/resource)")
		os.Exit(1)
	}

	var gvrs []schema.GroupVersionResource
	for _, arg := range args {
		parts := strings.SplitN(arg, "/", 3)
		if len(parts) != 3 {
			fmt.Fprintf(os.Stderr, "kwatch: invalid gvr %q (need group/version/resource)\n", arg)
			os.Exit(1)
		}
		gvrs = append(gvrs, schema.GroupVersionResource{Group: parts[0], Version: parts[1], Resource: parts[2]})
	}

	cfg := &rest.Config{Host: *proxyURL}
	dyn, err := dynamic.NewForConfig(cfg)
	if err != nil {
		fmt.Fprintln(os.Stderr, "kwatch:", err)
		os.Exit(1)
	}

	ctx, cancel := context.WithCancel(context.Background())
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGTERM, syscall.SIGINT)
	go func() { <-sigs; cancel() }()

	mu := &sync.Mutex{}
	out := bufio.NewWriter(os.Stdout)

	var wg sync.WaitGroup
	for _, gvr := range gvrs {
		wg.Add(1)
		go func(gvr schema.GroupVersionResource) {
			defer wg.Done()
			watchResource(ctx, dyn, gvr, mu, out)
		}(gvr)
	}
	wg.Wait()
}

func watchResource(ctx context.Context, dyn dynamic.Interface, gvr schema.GroupVersionResource, mu *sync.Mutex, out *bufio.Writer) {
	client := dyn.Resource(gvr)
	label := gvr.Group + "/" + gvr.Version + "/" + gvr.Resource

	list, err := client.List(ctx, metav1.ListOptions{Limit: 1})
	if err != nil {
		fmt.Fprintf(os.Stderr, "kwatch: list %s: %v\n", label, err)
		return
	}
	rv := list.GetResourceVersion()
	fmt.Fprintf(os.Stderr, "kwatch: watching %s from rv=%s\n", label, rv)

	rw, err := toolswatch.NewRetryWatcher(rv, &cache.ListWatch{
		WatchFunc: func(opts metav1.ListOptions) (watch.Interface, error) {
			return client.Watch(ctx, opts)
		},
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "kwatch: watch %s: %v\n", label, err)
		return
	}
	defer rw.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case ev, ok := <-rw.ResultChan():
			if !ok {
				return
			}
			type metaer interface {
				GetName() string
				GetNamespace() string
				GetResourceVersion() string
			}
			m, ok := ev.Object.(metaer)
			if !ok {
				continue
			}
			mu.Lock()
			fmt.Fprintf(out, "%s\t%s\t%s\t%s\t%s\n",
				ev.Type, label, m.GetNamespace(), m.GetName(), m.GetResourceVersion())
			out.Flush()
			mu.Unlock()
		}
	}
}
