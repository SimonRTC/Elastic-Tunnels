MANIFEST_NAME = elastic-tunnels
REGISTRY = registry.scaleship.org
REPOSITORY = network
REPOSITORY_TAG := $(shell git symbolic-ref --short HEAD)

export CGO_ENABLED := 0
build:
	GOARCH=amd64 GOOS=linux go build -o ./bin/connector-linux-amd64 ./cmd/connector/main.go
	GOARCH=amd64 GOOS=linux go build -o ./bin/consumer-linux-amd64 ./cmd/consumer/main.go
	GOARCH=amd64 GOOS=linux go build -o ./bin/controller-linux-amd64 ./cmd/controller/main.go
	GOARCH=386 GOOS=linux go build -o ./bin/connector-linux-i386 ./cmd/connector/main.go
	GOARCH=386 GOOS=linux go build -o ./bin/consumer-linux-i386 ./cmd/consumer/main.go
	GOARCH=386 GOOS=linux go build -o ./bin/controller-linux-i386 ./cmd/controller/main.go
	GOARCH=amd64 GOOS=windows go build -o ./bin/connector-windows-amd64 ./cmd/connector/main.go
	GOARCH=amd64 GOOS=windows go build -o ./bin/consumer-windows-amd64 ./cmd/consumer/main.go
	GOARCH=amd64 GOOS=windows go build -o ./bin/controller-windows-amd64 ./cmd/controller/main.go
	GOARCH=386 GOOS=windows go build -o ./bin/connector-windows-i386 ./cmd/connector/main.go
	GOARCH=386 GOOS=windows go build -o ./bin/consumer-windows-i386 ./cmd/consumer/main.go
	GOARCH=386 GOOS=windows go build -o ./bin/controller-windows-i386 ./cmd/controller/main.go

buildah:
	buildah manifest rm ${MANIFEST_NAME} 2> /dev/null || true
	buildah manifest create ${MANIFEST_NAME}
	buildah bud --tag "${REGISTRY}/${REPOSITORY}/${MANIFEST_NAME}:${REPOSITORY_TAG}" --manifest ${MANIFEST_NAME} --arch amd64 --build-arg BINARY_NAME=${MANIFEST_NAME} --build-arg BINARY_OS=linux --build-arg BINARY_ARCH=amd64 .
	buildah bud --tag "${REGISTRY}/${REPOSITORY}/${MANIFEST_NAME}:${REPOSITORY_TAG}" --manifest ${MANIFEST_NAME} --arch 386 --build-arg BINARY_NAME=${MANIFEST_NAME} --build-arg BINARY_OS=linux --build-arg BINARY_ARCH=i386 .
	buildah manifest push --all ${MANIFEST_NAME} "docker://${REGISTRY}/${REPOSITORY}/${MANIFEST_NAME}:${REPOSITORY_TAG}"

clean:
	go clean
	cd ./bin/ && find . -maxdepth 1 -type f -name '${MANIFEST_NAME}-*' -delete
	buildah manifest rm ${MANIFEST_NAME} 2> /dev/null || true