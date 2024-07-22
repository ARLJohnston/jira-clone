// Testing for main
package main

import (
	"context"
	"fmt"
	"github.com/testcontainers/testcontainers-go/modules/mongodb"
	"log"
	"testing"
)

func TestMain(t *testing.T) {
	ctx := context.Background()
	mongodbContainer, err := mongodb.Run(ctx, "mongo:6")
	if err != nil {
		log.Fatalf("failed to start container: %s", err)
	}

	// Clean up the container
	defer func() {
		if err := mongodbContainer.Terminate(ctx); err != nil {
			log.Fatalf("failed to terminate container: %s", err)
		}
	}()
	fmt.Printf("connected")

	// endpoint, err := container.Endpoint(ctx, "")
	// assert.NoError(t, err)

	t.Run("Placeholder Test", func(t *testing.T) {
		got := "Placeholder"
		want := "Placeholder"

		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	})
}
