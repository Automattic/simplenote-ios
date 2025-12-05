#!/bin/bash

set -euo pipefail

XCRESULT_PATH="${1:?Error: xcresult path required as first argument}"
DERIVED_DATA_PATH="${2:?Error: DerivedData path required as second argument}"

echo "--- :xcode: Store raw xcresulttool JSONs"

mkdir -p build/xcresulttool

xcrun xcresulttool get build-results \
  --path "$XCRESULT_PATH" \
  --format json > build/xcresulttool/xcresulttool-build-results.json

buildkite-agent artifact upload "build/xcresulttool/xcresulttool-build-results.json"

xcrun xcresulttool get test-results tests \
  --path "$XCRESULT_PATH" \
  --format json > build/xcresulttool/xcresulttool-tests-results.json

buildkite-agent artifact upload "build/xcresulttool/xcresulttool-tests-results.json"

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

echo "~~~ Dump xcactivitylog to JSON"

xclogparser dump \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --output build/xclogparser-reports/xcactivitylog-raw.json

buildkite-agent artifact upload "build/xclogparser-reports/xcactivitylog-raw.json"

echo "~~~ Generate JSON report"

xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter json > build/xclogparser-reports/report.json

buildkite-agent artifact upload "build/xclogparser-reports/report.json"

echo "~~~ Generate Chrome tracer report"

xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter chromeTracer > build/xclogparser-reports/build-trace.json

buildkite-agent artifact upload "build/xclogparser-reports/build-trace.json"

echo "--- :arrow_up::ruby: Upload build metrics to Apps Metrics"
ruby .buildkite/commands/upload_metrics.rb
