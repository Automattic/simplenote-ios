#! /bin/bash

set -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane pick_test_account_and_run_ui_tests scheme:"$1" device:"$2"
