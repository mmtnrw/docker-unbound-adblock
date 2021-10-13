#!/bin/sh

TAG=mmtnrw/unbound
BUILD=latest
UP=$TAG:$BUILD

docker build -t $UP .
docker push $UP
