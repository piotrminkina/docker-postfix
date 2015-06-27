#!/bin/sh
set -e


docker build \
    -t piotrminkina/postfix:2.5 \
    "$@" \
    src/

docker tag \
    -f \
    piotrminkina/postfix:2.5 \
    piotrminkina/postfix:latest
