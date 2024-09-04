#!/bin/bash -eu

.buildkite/commands/configure-environment.sh

echo '--- :git: Checkout release branch'
.buildkite/commands/checkout-release-branch.sh

echo '--- :closed_lock_with_key: Access secrets'
bundle exec fastlane run configure_apply

echo '--- :shipit: Complete code freeze'
bundle exec fastlane complete_code_freeze skip_confirm:true
