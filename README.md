# jira-clone
Jira clone using Go, gRPC, immutability and HTMX

## Workflow
Nix is used to manage dependencies, run tests and build the project

To enter into a shell with all project dependencies:
```bash
nix develop
```
This installs Go development tools (go, gopls, staticcheck)

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
