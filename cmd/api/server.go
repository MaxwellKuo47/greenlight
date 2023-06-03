package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func (app *application) serve() error {
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", app.config.port),
		Handler:      app.routes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		ErrorLog:     log.New(app.logger, "", 0),
	}
	shutdownError := make(chan error)

	go func() {
		quit := make(chan os.Signal, 1)
		acceptSignals := []os.Signal{syscall.SIGINT, syscall.SIGTERM}
		signal.Notify(quit, acceptSignals...)
		s := <-quit

		app.logger.PrintInfo("shutting down server", map[string]string{
			"signal": s.String(),
		})
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		shutdownError <- srv.Shutdown(ctx)
	}()

	app.logger.PrintInfo("starting server", map[string]string{
		"addr": srv.Addr,
		"env":  app.config.env,
	})
	/*
		app.logger.PrintInfo("db config info", map[string]string{
			"db-max-open-conns": fmt.Sprintf("%v", app.config.db.maxOpenConns),
			"db-max-idle-conns": fmt.Sprintf("%v", app.config.db.maxIdleConns),
			"db-max-idle-time":  app.config.db.maxIdleTime,
		})

		app.logger.PrintInfo("rate limiter info", map[string]string{
			"limiter-rps":     fmt.Sprintf("%v", app.config.limiter.rps),
			"limiter-burst":   fmt.Sprintf("%v", app.config.limiter.burst),
			"limiter-enabled": fmt.Sprintf("%v", app.config.limiter.enabled),
		})
	*/
	err := srv.ListenAndServe()
	if !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	err = <-shutdownError
	if err != nil {
		return err
	}

	app.logger.PrintInfo("stopped server", map[string]string{
		"addr": srv.Addr,
	})

	return nil
}
