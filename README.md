# jira-clone
[![codecov](https://codecov.io/github/ARLJohnston/jira-clone/graph/badge.svg?token=G9YO8HYCDG)](https://codecov.io/github/ARLJohnston/jira-clone)

Jira clone using Go, gRPC, immutability and HTMX

The prerequisites to running the project are stored in the [./flake.nix](flake devShell) buildInputs

## Workflow
Nix is used to manage dependencies, run tests and build the project

To enter into a shell with all project dependencies:
```bash
nix develop
```
This installs Go development tools (go, gopls, staticcheck)

If dependencies are missing use:
```bash
gomod2nix generate
```

To build and run the project as a binary use:
```bash
nix build .#bin
./result/bin/jira
```

To build and run the project as a Docker image use:
```bash
nix build .#docker
docker load < ./result
docker run jira-clone
```

To run all services:
```bash
nix build .#docker
docker load < ./result
docker compose up
```
