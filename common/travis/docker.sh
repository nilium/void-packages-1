#!/bin/sh
#
# docker.sh

[ "$XLINT" ] && exit 0

set -e

DOCKER_NAME=${DOCKER_NAME:-void}

/bin/echo -e "\x1b[32mPulling docker image $DOCKER_BASE-$BOOTSTRAP:$TAG...\x1b[0m"
docker image pull "$DOCKER_BASE-$BOOTSTRAP:$TAG"
docker container run \
	--detach \
	--name "$DOCKER_NAME" \
	--volume "$(pwd)":/hostrepo \
	--volume /tmp:/tmp \
	--env XLINT="$XLINT" \
	--env PATH="$PATH" \
	"$DOCKER_BASE-$BOOTSTRAP:$TAG" \
	/bin/sh -c 'sleep inf'
