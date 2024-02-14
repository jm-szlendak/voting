#!/bin/bash

set -ex

while :; do
  case $1 in
    --registry) REGISTRY=${2}
    shift;;
    --tag-as-latest) TAG_AS_LATEST=1
    ;;
    *) break
  esac
  shift
done

if [ -z "$REGISTRY" ]; then
  echo "Please provide a docker registry name with --registry option"
  exit 1
fi

docker login


# Get the current git commit sha
REVISION=$(git rev-parse  HEAD)
for service in services/*; do

  echo "Building $service..."
  # Check if the service has a Dockerfile
  if [ -f "$service/Dockerfile" ]; then

    service_name=$(basename "$service");
    docker build -t "$REGISTRY/$service_name:$REVISION" "$service";
    
    docker push "$REGISTRY/$service_name:$REVISION";

    if [ "$TAG_AS_LATEST" ]; then
      docker tag "$REGISTRY/$service_name:$REVISION" "$REGISTRY/$service_name:latest";
      docker push "$REGISTRY/$service_name:latest";
    fi
  fi
done

