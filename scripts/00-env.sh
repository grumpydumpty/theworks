#
# NOTE:
# The values here are used by the scripts to override values in Dockerfile.
# Unfortunately, "docker build" doesn't work with a .env file (or similar)
# so the Dockerfile contains duplicate definitions that need to be keep in 
# sync with the definitions in this file.
#

BASE=${PWD}

# image and container name
IMAGE=theworks
CONTAINER=$IMAGE

# image tag
TAG=dev

# image version
VERSION=0.0.1

# project info
PROJECT="grumpydumpty/theworks"

# maintainer info
MAIN_USER="Richard Croft"
MAIN_EMAIL="rcroft@omnissa.com"
MAIN_URL="https://github.com/grumpydumpty"

# below needs to match "ARG LABEL_PREFIX=" in Dockerfile
LABEL_PREFIX=net.lab

# domain name for container hostname
DOMAIN="lab.net"

# working dir within the container
WORKDIR="/workspace"

# repository to push image to
#REPO=harbor.sydeng.vmware.com/rcroft
#REPO=ghcr.io/grumpydumpty/${IMAGE}
REPO=artifactory.build.omnissa.com/uem-platform-eng-docker
