FROM golang AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o jira ./cmd/jira

FROM builder AS run-tests
RUN go test -v ./...

FROM alpine
LABEL org.opencontainers.image.source https://github.com/arljohnston/jira-clone
COPY --from=builder /app /
CMD ["/jira"]
