#!/bin/bash

source scripts/00-env.sh

#############################################################################
# build docker image

# build new docker image
docker build                                                                           \
    -t $IMAGE:$TAG                                                                     \
    --label "$LABEL_PREFIX.version=$VERSION"                                           \
    --label "$LABEL_PREFIX.git.repo=$(git remote -v | cut -f2 | cut -f1 -d' ' | uniq)" \
    --label "$LABEL_PREFIX.git.commit=$(git rev-parse --short HEAD)"                   \
    --label "$LABEL_PREFIX.maintainer.name=$MAIN_USER"                                 \
    --label "$LABEL_PREFIX.maintainer.email=$MAIN_EMAIL"                               \
    --label "$LABEL_PREFIX.maintainer.url=$MAIN_URL"                                   \
    --label "$LABEL_PREFIX.builder.name=$(git config user.name)"                       \
    --label "$LABEL_PREFIX.builder.email=$(git config user.email)"                     \
    --label "$LABEL_PREFIX.released=$(date "+%Y-%m-%d")"                               \
    --label "$LABEL_PREFIX.based-on=$IMAGE:$TAG"                                       \
    --label "$LABEL_PREFIX.project=$PROJECT"                                           \
    .

#############################################################################
# dump metadata labels
echo
echo "#### Labels ####"
echo
# when jq not installed
#docker inspect $IMAGE:$TAG --format '{{ json .Config.Labels }}' | sed 's/,/\n/g; s/{//g; s/}//g; s/"//g'
# when jq installed
docker inspect $IMAGE:$TAG --format '{{ json .Config.Labels }}' | jq
echo

#############################################################################
# update latest tag to dev
#docker tag $IMAGE:$TAG $IMAGE:latest

#############################################################################
# vim: set syn=sh ft=unix ts=4 sw=4 et tw=78:
