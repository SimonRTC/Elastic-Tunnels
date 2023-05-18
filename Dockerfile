FROM docker.io/alpine:3.17.3 as alpine

# Update CA certificates package from alpine image
RUN apk update
RUN apk add --no-cache ca-certificates
    
RUN update-ca-certificates

FROM scratch

# Set default home directory as "/tunnels"
WORKDIR /tunnels

# Declare build arguments
ARG BINARY_OS
ARG BINARY_ARCH

# Import application binaries from local file system
COPY ./bin/connector-${BINARY_OS}-${BINARY_ARCH} /tunnels/connector
COPY ./bin/consumer-${BINARY_OS}-${BINARY_ARCH} /tunnels/consumer
COPY ./bin/controller-${BINARY_OS}-${BINARY_ARCH} /tunnels/controller

# Import CA certificates from alpine image
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT [ "/tunnels/consumer" ]
