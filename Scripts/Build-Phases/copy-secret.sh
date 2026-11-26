#!/usr/bin/env bash

set -euo pipefail

# The first argument is the committed `.age` blob. The phase lists it as an input
# so a pull that rotates the secret re-runs it; the plaintext comes from
# `a8c-secrets which`, decrypted by the `Decrypt Secrets` aggregate target.
if [[ $# -ne 3 ]]; then
  echo "error: Usage: $0 encrypted_secret_path external_secret_path output_path"
  exit 1
fi

SECRET_NAME=$(basename "$1" .age)
EXTERNAL_SECRET_PATH=$2
OUTPUT_PATH=$3

# Build phases don't inherit the shell's PATH, so point at a8c-secrets' default
# install location.
export PATH="$HOME/.local/bin:$PATH"

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

# `a8c-secrets which` exits non-zero when the file has not been decrypted.
if command -v a8c-secrets > /dev/null 2>&1 && INTERNAL_SECRET_PATH=$(a8c-secrets which "$SECRET_NAME" 2>/dev/null); then
  apply "$INTERNAL_SECRET_PATH"
fi

if [[ -f "$EXTERNAL_SECRET_PATH" ]]; then
  if [[ "${CONFIGURATION:-}" == Distribution* ]]; then
    echo "error: Refusing to build the '${CONFIGURATION}' configuration with external contributor credentials from '${EXTERNAL_SECRET_PATH}'. Distribution builds need the production credentials from a8c-secrets, see https://github.com/Automattic/a8c-secrets."
    exit 1
  fi
  apply "$EXTERNAL_SECRET_PATH"
fi

echo "error: No secrets found! Internal contributors: install a8c-secrets and follow its setup instructions, see https://github.com/Automattic/a8c-secrets. External contributors: copy '${EXTERNAL_SECRET_PATH%.external-contributors.swift}.template.swift' to '${EXTERNAL_SECRET_PATH}' and fill in your own credentials."
exit 1
