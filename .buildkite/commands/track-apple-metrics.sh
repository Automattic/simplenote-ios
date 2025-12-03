#!/bin/bash

set -euo pipefail

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
echo "~~~ Dump xcactivitylog to JSON"
xclogparser dump \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data ./DerivedData \
  --output build/xclogparser-reports/xcactivitylog-raw.json
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

