#!/bin/bash

set -euo pipefail

XCRESULT_PATH=""
DERIVED_DATA_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --xcresult-path)
      XCRESULT_PATH="$2"
      shift 2
      ;;
    --derived-data-path)
      DERIVED_DATA_PATH="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$XCRESULT_PATH" ]]; then
  echo "Error: --xcresult-path is required" >&2
  exit 1
fi

if [[ -z "$DERIVED_DATA_PATH" ]]; then
  echo "Error: --derived-data-path is required" >&2
  exit 1
fi

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

xclogparser_json_path=build/xclogparser-reports/report.json
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter json > "$xclogparser_json_path"

buildkite-agent artifact upload "$xclogparser_json_path"

echo "~~~ Generate Chrome tracer report"

xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter chromeTracer > build/xclogparser-reports/build-trace.json

buildkite-agent artifact upload "build/xclogparser-reports/build-trace.json"

# This could be inlined once/if moving ti CI toolkit
echo "--- :arrow_up: Upload to Apps Metrics"
.buildkite/commands/upload-metrics.sh \
  --xcresult-path "$XCRESULT_PATH" \
  --xclogparser-json "$xclogparser_json_path"
