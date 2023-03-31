#!/bin/bash

source ./00-env.sh

#############################################################################
# tag and push the image to public repository

# tag the image
docker tag ${IMAGE}:${TAG} ${REPO}/${IMAGE}:${TAG}

# log into repo
#docker login https://${REPO}

# push the image to repo
docker push ${REPO}/${IMAGE}:${TAG}

#############################################################################
# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:
