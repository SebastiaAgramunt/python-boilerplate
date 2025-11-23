#!/bin/bash

THIS_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$THIS_DIR/..")

DOCKERFILE=python-3.13


build_image(){
    docker build -f Docker/Dockerfile-${DOCKERFILE} \
                --build-arg USERNAME=$(whoami) \
                --build-arg UID=$(id -u) \
                --build-arg GID=$(id -g) \
                 -t ${DOCKERFILE}-image .
}

run_image(){
    docker run \
    -v ${ROOT_DIR}:/home/$(whoami) \
    -it \
    ${DOCKERFILE}-image \
     /bin/bash
}

croak(){
    echo "[ERROR] $*" > /dev/stderr
    exit 1
}

main(){
    if [[ -z "$TASK" ]]; then
        croak "No TASK specified."
    fi
    echo "[INFO] running $TASK $*"
    $TASK "$@"
}

main "$@"

# TASK=build_image ./Docker/build-run.sh
# TASK=run_image ./Docker/build-run.sh