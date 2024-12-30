REGISTRY:=harbor.k01.satoruh.org
REPOSITORY:=library/speedtest
TAG:=latest

ARTIFACT:=$(REGISTRY)/$(REPOSITORY):$(TAG)

.PHONY: build
build:
	docker build -t $(ARTIFACT) .

.PHONY: push
push: build
	docker push $(ARTIFACT)
