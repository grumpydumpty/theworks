#############################################################################
##
## makefile
##

#############################################################################
## env vars with default values, used for image labels
##

## base directory
BASE  ?=  $(shell pwd)

## image and container info
IMAGE ?= theworks
CONTAINER ?= $(IMAGE)
TAG ?= dev
VERSION ?= 0.0.1

## project info
PROJECT ?= "grumpydumpty/$(IMAGE)"

## maintainer info
MAIN_USER ?= "grumpydumpty"
MAIN_NAME ?= "Richard Croft"
MAIN_EMAIL ?= "arjaycroft@gmail.com"
MAIN_URL ?= "https://github.com/$(MAIN_USER)"

## below needs to match "ARG LABEL_PREFIX=" in Dockerfile
LABEL_PREFIX ?= "net.lab"

## domain name for container hostname
DOMAIN ?= lab.net

## working dir within the container
WORKDIR ?= /workspace

## repository to push image to
REPO ?= "ghcr.io/grumpydumpty"

#############################################################################
## targets
##

.PHONY: all docs-build docs-serve docker-build docker-labels docker-shell docker-serve docker-stop docker-push clean list

all: clean build docker-builder

## build statics docs site
docs-build:
	@mkdocs build -f mkdocs.yml

## monitor for docs changes and serve latest
docs-serve:
	@mkdocs serve -f mkdocs.yml --dev-addr=0.0.0.0:80

## clean up generated docs site
clean:
	@rm -rf .site/

## build new docker image
docker-build:
	@docker build                                                                                       \
		-t $(IMAGE):$(TAG)                                                                              \
		--label "$(LABEL_PREFIX).version=$(VERSION)"                                                    \
		--label "$(LABEL_PREFIX).git.repo=$(git remote -v | cut -f2 | cut -f1 -d' ' | uniq | head -n1)" \
		--label "$(LABEL_PREFIX).git.commit=$(git rev-parse --short HEAD)"                              \
		--label "$(LABEL_PREFIX).maintainer.name=$(MAIN_NAME)"                                          \
		--label "$(LABEL_PREFIX).maintainer.email=$(MAIN_EMAIL)"                                        \
		--label "$(LABEL_PREFIX).maintainer.url=$(MAIN_URL)"                                            \
		--label "$(LABEL_PREFIX).builder.name=$(git config user.name)"                                  \
		--label "$(LABEL_PREFIX).builder.email=$(git config user.email)"                                \
		--label "$(LABEL_PREFIX).released=$(date "+%Y-%m-%d")"                                          \
		--label "$(LABEL_PREFIX).based-on=$(IMAGE):$(TAG)"                                              \
		--label "$(LABEL_PREFIX).project=$(PROJECT)"                                                    \
		.

## dump metadata labels
docker-labels:
	@docker inspect $(IMAGE):$(TAG) --format '{{ json .Config.Labels }}' | jq
	@echo

## run in foreground
docker-shell:
	@clear
	@docker run -it --rm -v $(PWD):$(WORKDIR) -h $(CONTAINER).$(DOMAIN) --name $(CONTAINER) $(IMAGE):$(TAG)

## run in background serving docs
docker-serve:
	@docker run -d --rm -v $(PWD):$(WORKDIR) -h $(CONTAINER).$(DOMAIN) --name $(CONTAINER) $(IMAGE):$(TAG) mkdocs serve -f mkdocs.yml --dev-addr=0.0.0.0:80

## stop running container
docker-stop:
	@docker container stop $(CONTAINER)

## tag image, log into docker hub, and push image
docker-push:
	@docker tag $(IMAGE):$(TAG) $(REPO)/$(IMAGE):$(TAG)
	#@docker login https://$(REPO)
	#@docker push $(REPO)/$(IMAGE):$(TAG)

## clean up docker artifacts
docker-clean: clean
	@docker rmi $(IMAGE):$(TAG)
	@docker rmi $(IMAGE):latest
	@docker system prune -f

## NOTE:
## - this is for GNU make 4.3 and earlier.
## - GNU make 4.4 onwards has a `--list-targets` command line switch
##
## The list target was taken from here:
## - [Stack Overflow](https://stackoverflow.com/a/26339924)

## list all makefile targets
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

# vim: set syn=makefile ft=unix ts=4 sw=4 sts=0 noet tw=78:
