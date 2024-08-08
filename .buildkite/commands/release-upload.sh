#!/bin/bash -eu

echo "--- :arrow_down: Downloading Artifacts"
ARTIFACTS_DIR='build/results'
STEP=testflight_build
buildkite-agent artifact download "$ARTIFACTS_DIR/*.ipa" . --step $STEP
buildkite-agent artifact download "$ARTIFACTS_DIR/*.zip" . --step $STEP

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Upload to App Store Connect"
bundle exec fastlane upload_to_app_store_connect \
  skip_confirm:true \
  skip_prechecks:true \
  create_release:true \
  "beta_release:${1:-true}" # use first call param, default to true for safety
