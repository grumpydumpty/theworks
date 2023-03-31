#
# NOTE:
# The values here are used by the scripts to override values in Dockerfile.
# Unfortunately, "docker build" doesn't work with a .env file (or similar)
# so the Dockerfile contains duplicate definitions that need to be keep in 
# sync with the definitions in this file.
#

# image and container name
IMAGE=theworks
CONTAINER=$IMAGE

# image tag
TAG=dev

# image version
VERSION=0.0.1

# below needs to match "ARG LABEL_PREFIX=" in Dockerfile
LABEL_PREFIX=com.vmware.eocto

# repository to push image to
#REPO=harbor.sydeng.vmware.com/rcroft
REPO=harbor.sydeng.vmware.com/library
