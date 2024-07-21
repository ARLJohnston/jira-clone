// Testing for main
package main

import (
	"context"
	"fmt"
	"testing"

	"github.com/docker/go-connections/nat"
	"github.com/stretchr/testify/assert"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func TestMain(t *testing.T) {
	ctx := context.Background()

	port, err := nat.NewPort("", "27017")
	assert.NoError(t, err)

	req := testcontainers.ContainerRequest{
		Image:        "mongo:latest",
		ExposedPorts: []string{string(port)},
		WaitingFor:   wait.ForListeningPort(port),
	}

	fmt.Println("Request succeeded")

	_, err = testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	assert.NoError(t, err)

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
