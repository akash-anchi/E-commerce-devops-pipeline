#!/bin/bash
set -e

BRANCH=$1

if [ "$BRANCH" == "dev" ]; then
    IMAGE="in29mins/devops-app-dev:latest"
elif [ "$BRANCH" == "master" ]; then
    IMAGE="in29mins/devops-app-prod:latest"
else
    echo "Branch not supported. Use dev or master only."
    exit 1
fi

echo "Building image: $IMAGE"
docker build -t $IMAGE .
docker push $IMAGE

echo "Image pushed: $IMAGE"
