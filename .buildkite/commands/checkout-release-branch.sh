#!/bin/bash -eu

RELEASE_VERSION=$1

if [[ -z "${RELEASE_VERSION}" ]]; then
    echo "Usage $0 <release version, e.g. 1.2.3>"
    exit 1
fi

# Buildkite, by default, checks out a specific commit.
# For many release actions, we need to be on a release branch instead.
BRANCH_NAME="release/${RELEASE_VERSION}"
git fetch origin "$BRANCH_NAME"
git checkout "$BRANCH_NAME"
