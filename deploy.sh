#!/bin/bash

while :; do
  case $1 in
    --env) environment=${2}
    shift;;
    --tag) tag=${2}
    shift;;
    *) break
  esac
  shift
done

if [ -z "$environment" ]; then
  echo "Please provide environment name with --env option"
  exit 1
fi

if [ -z "$tag" ]; then
  echo "Please docker image tag to be released with --tag option"
  exit 1
fi


cd iac/tf

terraform apply --var "environment=$environment" --var "tag=$tag" --auto-approve

cd ../..