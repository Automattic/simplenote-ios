#!/usr/bin/env bash

set -euo pipefail

# The `Decrypt Secrets` and `Copy Secret` build phases put this directory on their own PATH.
install_a8c-secrets_binary --install-dir "$HOME/.local/bin"
