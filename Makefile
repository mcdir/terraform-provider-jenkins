BINARY=terraform-provider-jenkins

.DEFAULT_GOAL: $(BINARY)

$(BINARY):
	go build -o bin/$(BINARY)

test:
	go test -v

docker_test:
	go test -v

build:
	go build -o bin/$(BINARY)

test_integration: build build_jenkins_docker_image
	cd test && \
	./test_integration.sh

build_jenkins_docker_image:
	cd test/docker-jenkins && \
	docker build -t tarmak-jenkins:$$(cat Dockerfile plugins.txt | md5sum | awk '{print $$1}') -t tarmak-jenkins:latest .
