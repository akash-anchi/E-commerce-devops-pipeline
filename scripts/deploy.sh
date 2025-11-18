#!/bin/bash
set -e

IMAGE="in29mins/devops-app-prod:latest"
CONTAINER="devops-app"

docker pull $IMAGE

docker stop $CONTAINER || true
docker rm $CONTAINER || true

docker run -d --name $CONTAINER -p 80:80 --restart unless-stopped $IMAGE
