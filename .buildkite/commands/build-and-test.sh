#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Build and Test"
set +e
bundle exec fastlane run_unit_tests
TESTS_EXIT_STATUS=$?
set -e

if [[ $TESTS_EXIT_STATUS -ne 0 ]]; then
  # Keep the (otherwise collapsed) current "Testing" section open in Buildkite logs on error. See https://buildkite.com/docs/pipelines/managing-log-output#collapsing-output
  echo "^^^ +++"
  echo "Unit Tests failed!"
fi

echo "--- 📦 Zipping test results"
cd build/results/ && zip -rq Simplenote.xcresult.zip Simplenote.xcresult && cd -

echo "--- :s3: Upload xcactivitylog to S3"
aws s3 cp DerivedData s3://a8c-apps-metrics/simplenote-ios/ \
  --recursive \
  --exclude "*" \
  --include "*.xcactivitylog"

echo "--- :arrow_up: Sync with Apps Metrics"
API_URL='https://metrics.a8c-ci.services/api/pending-build-logs'
TOKEN="$APPS_METRICS_UPLOAD_TOKEN"

for file in DerivedData/Logs/Build/*.xcactivitylog; do
  filename=$(basename "$file")

  echo "📤 Posting $filename to $API_URL ..."

  arch_val=$(arch)
  os_val="$(sw_vers -productName) $(sw_vers -productVersion)"
  branch_val="${BUILDKITE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

  curl -s -o /dev/null -w "\nHTTP CODE: %{http_code}\n" \
    -X POST "$API_URL" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
        \"file_path\": \"simplenote-ios/Logs/Build/$filename\",
        \"type\": \"xcactivitylog\",
        \"meta\": [
          { \"name\": \"simplenote-ios-user\", \"value\": \"CI\" },
          { \"name\": \"simplenote-ios-environment\", \"value\": \"CI\" },
          { \"name\": \"simplenote-ios-architecture\", \"value\": \"$arch_val\" },
          { \"name\": \"simplenote-ios-operating-system\", \"value\": \"$os_val\" },
          { \"name\": \"simplenote-ios-metrics-source\", \"value\": \"xcactivitylog\" },
          { \"name\": \"simplenote-ios-branch\", \"value\": \"$branch_val\" }
        ]
      }"

  echo " ✅ $filename queued"
done

echo "--- :xcode: Store raw xcresulttool JSONs"
mkdir -p build/xcresulttool
xcrun xcresulttool get build-results \
  --path build/results/Simplenote.xcresult \
  --format json > build/xcresulttool/xcresulttool-build-results.json
xcrun xcresulttool get test-results tests \
  --path build/results/Simplenote.xcresult \
  --format json > build/xcresulttool/xcresulttool-tests-results.json

echo "+++ :json: Extract build info from xcresulttool"
jq '{
  timestamp: .startTime | strftime("%Y-%m-%d %H:%M:%S"),
  duration_ms: ((.endTime - .startTime) * 1000 | round),
  status: .status,
  errors: .errorCount,
  warnings: .warningCount,
  analyzer_warnings: .analyzerWarningCount,
  warning_breakdown: (.warnings | group_by(.issueType) | map({type: .[0].issueType, count: length}) | sort_by(-.count))
}' build/xcresulttool/xcresulttool-build-results.json

echo "+++ :json: Extract success/fail test count from xcresulttool"
jq '[.. | objects | select(has("result")) | .result] | {passed: map(select(. == "Passed")) | length, failed: map(select(. == "Failed")) | length}' \
  build/xcresulttool/xcresulttool-tests-results.json

echo "--- :xcode: Track XCLogParser report"
echo "~~~ Install XCLogParser"
brew install xclogparser
mkdir -p build/xclogparser-reports
echo "~~~ Generate HTML report"
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data ./DerivedData \
  --reporter html \
  --rootOutput build/xclogparser-reports
echo "~~~ Generate JSON report"
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data ./DerivedData \
  --reporter json > build/xclogparser-reports/report.json

echo "--- :arrow_up::ruby: Upload build metrics to Apps Metrics"
ruby .buildkite/commands/upload_metrics.rb

echo "~~~ Annotate build"
buildkite-agent annotate "[View build report](artifact://build/reports/index.html)" \
  --style "info"

echo "--- 🚦 Report Tests Status"
if [[ $TESTS_EXIT_STATUS -eq 0 ]]; then
  echo "Unit Tests seems to have passed (exit code 0). All good 👍"
else
 echo "The Unit Tests, ran during the '🛠️ Build and Test' step above, have failed."
  echo "For more details about the failed tests, check the Buildkite annotation, the logs under the '🛠️ Build and Test' section and the \`.xcresult\` and test reports in Buildkite artifacts."
fi
annotate_test_failures "build/results/report.junit"

exit $TESTS_EXIT_STATUS
