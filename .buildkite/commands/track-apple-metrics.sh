#!/bin/bash

set -euo pipefail

# Accept paths as inputs, with sensible defaults
XCRESULT_PATH="${1:-build/results/Simplenote.xcresult}"
DERIVED_DATA_PATH="${2:-./DerivedData}"

echo "--- :xcode: Store raw xcresulttool JSONs"

mkdir -p build/xcresulttool

xcrun xcresulttool get build-results \
  --path "$XCRESULT_PATH" \
  --format json > build/xcresulttool/xcresulttool-build-results.json

xcrun xcresulttool get test-results tests \
  --path "$XCRESULT_PATH" \
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
echo "~~~ Dump xcactivitylog to JSON"
xclogparser dump \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --output build/xclogparser-reports/xcactivitylog-raw.json
echo "~~~ Generate HTML report"
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter html \
  --rootOutput build/xclogparser-reports
echo "~~~ Generate JSON report"
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter json > build/xclogparser-reports/report.json

echo "--- :buildkite: Upload JSON artifacts"
buildkite-agent artifact upload "build/xcresulttool/*.json"
buildkite-agent artifact upload "build/xclogparser-reports/*.json"

