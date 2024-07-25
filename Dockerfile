FROM golang AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o jira ./cmd/jira

FROM builder AS run-tests
RUN go test -v ./...

FROM alpine
COPY --from=builder /app /
CMD ["/jira"]
