#!/bin/bash

source scripts/00-env.sh

#############################################################################
# stop the latest docker image
# (doesn't really make sense with this image as it's running run interactively)
docker container stop $CONTAINER

#############################################################################
# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:
