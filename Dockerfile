# Use the official Go image with Alpine
FROM golang:1.21-alpine AS builder

# Install git and ca-certificates
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# First copy only go.mod to optimize Docker layer caching
COPY go.mod .
RUN go mod download

# Then copy the rest of the files
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-w -s' -o /app/myapp .

# Final stage
FROM alpine:latest

# Install CA certificates
RUN apk add --no-cache ca-certificates

# Create non-root user
RUN adduser -D appuser
USER appuser

WORKDIR /home/appuser

# Copy binary from builder
COPY --from=builder --chown=appuser:appuser /app/myapp .

CMD ["./myapp"]