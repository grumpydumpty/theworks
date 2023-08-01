#!/bin/bash

source scripts/00-env.sh

#############################################################################
# run the latest docker image

# run in background 
# (doesn't really make sense with this image as it needs to run interactively)
#docker run -dit --rm -v $PWD:/workspace --name $CONTAINER $IMAGE:$TAG

# run in foreground
docker run -it --rm -v $PWD:/workspace --name $CONTAINER $IMAGE:$TAG

#############################################################################
# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:
