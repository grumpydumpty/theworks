#!/bin/bash

source scripts/00-env.sh

#############################################################################
# clean our images
docker rmi $IMAGE:$TAG
docker rmi $IMAGE:latest

#############################################################################
# clean up any leftovers
for i in container image volume network;
do
    docker $i prune -f
done

#############################################################################
# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:
