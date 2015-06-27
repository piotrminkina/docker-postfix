#!/bin/sh
set -e


LIB_DIR=${LIB_DIR:-/var/lib/postfix/}
SPOOL_DIR=${SPOOL_DIR:-/var/spool/postfix/}


docker run \
    --name postfix \
    --rm \
    --read-only \
    -v "${LIB_DIR}":/var/lib/postfix/ \
    -v "${SPOOL_DIR}":/var/spool/postfix/ \
    piotrminkina/postfix
    postfix-check

docker run \
    --name postfix \
    --rm \
    --read-only \
    -v "${LIB_DIR}":/var/lib/postfix/ \
    -v "${SPOOL_DIR}":/var/spool/postfix/ \
    "$@" \
    piotrminkina/postfix
