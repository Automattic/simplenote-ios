#!/usr/bin/env bash

set -euo pipefail

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Build and Test"
set +e
bundle exec fastlane run_ui_tests scheme:"$1" device:"$2"
TESTS_EXIT_STATUS=$?
set -e

if [[ $TESTS_EXIT_STATUS -ne 0 ]]; then
  # Keep the (otherwise collapsed) current "Testing" section open in Buildkite logs on error. See https://buildkite.com/docs/pipelines/managing-log-output#collapsing-output
  echo "^^^ +++"
  echo "UI Tests failed!"
fi

echo "--- 📦 Zipping test results"
cd build/results/ && zip -rq SimplenoteUITests.xcresult.zip SimplenoteUITests.xcresult && cd -

echo "--- 🚦 Report Tests Status"
if [[ $TESTS_EXIT_STATUS -eq 0 ]]; then
  echo "UI Tests seems to have passed (exit code 0). All good 👍"
else
  echo "The UI Tests, ran during the '🛠️ Build and Test' step above, have failed."
  echo "For more details about the failed tests, check the Buildkite annotation, the logs under the '🛠️ Build and Test' section and the \`.xcresult\` and test reports in Buildkite artifacts."
fi
annotate_test_failures "build/results/report.junit"

exit $TESTS_EXIT_STATUS
