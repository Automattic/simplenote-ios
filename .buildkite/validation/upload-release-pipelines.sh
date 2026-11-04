#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source .buildkite/shared-pipeline-vars

# No such branch on origin, so the real `checkout_release_branch` fails rather than leaving the commit under test.
export RELEASE_VERSION=99.9

for pipeline in \
  complete-code-freeze \
  new-beta-release \
  finalize-release \
  publish-release \
  update-metadata-on-app-store-connect; do
  buildkite-agent pipeline upload ".buildkite/release-pipelines/$pipeline.yml"
done

buildkite-agent pipeline upload .buildkite/validation/release-upload.yml
