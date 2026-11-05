#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "error: Usage: $0 internal_secret_path external_secret_path output_path"
  exit 1
fi

INTERNAL_SECRET_PATH=$1
EXTERNAL_SECRET_PATH=$2
OUTPUT_PATH=$3

apply() {
  # Leaving an unchanged output untouched avoids recompiling the target.
  if cmp --silent -- "$1" "$OUTPUT_PATH"; then
    echo "☑️ Credentials were not modified. Skipping..."
    exit 0
  fi

  mkdir -p "$(dirname "$OUTPUT_PATH")"
  cp -v "$1" "$OUTPUT_PATH"
  exit 0
}

if [[ -f "$INTERNAL_SECRET_PATH" ]]; then
  apply "$INTERNAL_SECRET_PATH"
fi

if [[ -f "$EXTERNAL_SECRET_PATH" ]]; then
  apply "$EXTERNAL_SECRET_PATH"
fi

echo "error: No secrets found! Internal contributors: run \`bundle exec fastlane run configure_apply\`. External contributors: copy '${EXTERNAL_SECRET_PATH%.external-contributors.swift}.template.swift' to '${EXTERNAL_SECRET_PATH}' and fill in your own credentials."
exit 1
