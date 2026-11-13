#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :swift: Restoring Swift Package Manager cache"
restore_swiftpm_cache --package-resolved Simplenote.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Build for App Store Connect"
bundle exec fastlane build_for_app_store_connect
