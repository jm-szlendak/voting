#!/bin/bash

set -ex

while :; do
  case $1 in
    --repository) REPOSITORY=${2}
    shift;;
    --tag-as-latest) TAG_AS_LATEST=1
    ;;
    *) break
  esac
  shift
done

if [ -z "$REPOSITORY" ]; then
  echo "Please provide a docker repository name with --repository option"
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
    docker build -t "$REPOSITORY/$service_name:$REVISION" "$service";
    
    docker push "$REPOSITORY/$service_name:$REVISION";

    if [ "$TAG_AS_LATEST" ]; then
      docker tag "$REPOSITORY/$service_name:$REVISION" "$REPOSITORY/$service_name:latest";
      docker push "$REPOSITORY/$service_name:latest";
    fi
  fi
done

