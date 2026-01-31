FROM alpine:3.19

# Install Go + dependencies
RUN apk add --no-cache \
    go \
    bash \
    ca-certificates \
    openssl \
    lftp \
    git \
    unzip

# Add Basemap CA cert
COPY basemap-ca.pem /usr/local/share/ca-certificates/basemap-ca.crt
RUN update-ca-certificates

WORKDIR /app

# Copy Go module files first
COPY go.mod go.sum ./

# Download dependencies
RUN go mod tidy
RUN go get github.com/lib/pq@latest

# Copy source files
COPY entrypoint.sh main.go ./

# Build Go binary
RUN go build -o txc-loader main.go

# Ensure entrypoint is executable
RUN chmod +x entrypoint.sh txc-loader

# Run entrypoint
CMD ["./entrypoint.sh"]

