#!/bin/bash

SOURCE_PATH=$1
TARGET_PATH=$2

USAGE="error: Usage $0 source_path target_path"

if [[ -z ${SOURCE_PATH:+x} || -z ${TARGET_PATH:+x} ]]; then
  echo $USAGE
  exit 1
fi

git check-ignore "${TARGET_PATH}" > /dev/null
GIT_IGNORE_EXIT_CODE=$?
if [ $GIT_IGNORE_EXIT_CODE -ne 0 ]; then
    echo "error: Attempting to store secret file in path that is not ignored by Git (${TARGET_PATH})."
    exit 1
fi

if [ ! -f ${SOURCE_PATH} ]; then
    echo "error: Unable to copy credentials. Could not find ${SOURCE_PATH}."
    exit 1
else
    echo "Copying credentials..."
    mkdir -p ${TARGET_FOLDER}
    cp ${SOURCE_PATH} ${TARGET_PATH}
fi
