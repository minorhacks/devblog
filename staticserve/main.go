package main

import (
	"context"
	"flag"
	"log/slog"
	"net/http"
	"os"

	"github.com/VictoriaMetrics/metrics"
	"github.com/go-chi/chi/v5"
)

var (
	flagHttpAddress  = flag.String("http_address", ":8080", "host:port to listen for site requests")
	flagDebugAddress = flag.String("debug_address", "127.0.0.1:8081", "host:port for debug endpoints")
	flagServeDir     = flag.String("serve_dir", "", "directory from which static files are served")
)

func appMain(ctx context.Context) error {
	debugRouter := chi.NewRouter()
	debugRouter.Get("/metrics", func(w http.ResponseWriter, req *http.Request) {
		metrics.WritePrometheus(w, true)
	})
	slog.Info("Listening for debug endpoints", slog.String("address", *flagDebugAddress))
	go http.ListenAndServe(*flagDebugAddress, debugRouter)

	r := chi.NewRouter()
	fs := http.FileServer(http.Dir(*flagServeDir))
	r.Handle("/*", fs)
	slog.Info(
		"Listening for HTTP requests",
		slog.String("address", *flagHttpAddress),
		slog.String("serve_dir", *flagServeDir),
	)
	return http.ListenAndServe(*flagHttpAddress, r)
}

func main() {
	flag.Parse()
	ctx := context.Background()
	if err := appMain(ctx); err != nil {
		slog.Error("Exiting due to error", slog.Any("err", err))
		os.Exit(1)
	}
}
