#!/bin/bash

set -euo pipefail

PREFIX='simplenote-ios'
METRICS_URL="${METRICS_URL:-https://metrics.a8c-ci.services/api/grouped-metrics}"
TOKEN="${APPS_METRICS_UPLOAD_TOKEN:-}"

DRY_RUN=false
XCRESULT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      XCRESULT_PATH="$1"
      shift
      ;;
  esac
done

XCRESULT_PATH="${XCRESULT_PATH:-build/results/Simplenote.xcresult}"

if [[ "$DRY_RUN" == false && -z "$TOKEN" ]]; then
  echo "No APPS_METRICS_UPLOAD_TOKEN found in environment." >&2
  exit 1
fi

# Metadata
USER_NAME="${USER:-${USERNAME:-unknown}}"
PROJECT="simplenote-ios"
ENVIRONMENT="${CI:+CI}"
ENVIRONMENT="${ENVIRONMENT:-LOCAL}"
ARCHITECTURE=$(uname -m)
OPERATING_SYSTEM=$(uname -s | tr '[:upper:]' '[:lower:]')
BRANCH="${BUILDKITE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

echo "Extracting build results from $XCRESULT_PATH..."
build_json=$(xcrun xcresulttool get build-results --path "$XCRESULT_PATH" --format json)

# Core build metrics
end_time=$(echo "$build_json" | jq '(.endTime * 1000) | round')
start_time=$(echo "$build_json" | jq '(.startTime * 1000) | round')
build_time=$((end_time - start_time))
action_title=$(echo "$build_json" | jq -r '.actionTitle')
analyzer_warning_count=$(echo "$build_json" | jq '.analyzerWarningCount')
error_count=$(echo "$build_json" | jq '.errorCount')
status=$(echo "$build_json" | jq -r '.status')
warning_count=$(echo "$build_json" | jq '.warningCount')

# Warning breakdown by type
warning_deprecation_count=$(echo "$build_json" | jq '[.warnings[] | select(.issueType == "DeprecatedDeclaration")] | length')
warning_preprocessor_count=$(echo "$build_json" | jq '[.warnings[] | select(.issueType == "Lexical or Preprocessor Issue")] | length')
warning_swift_compiler_count=$(echo "$build_json" | jq '[.warnings[] | select(.issueType == "Swift Compiler Warning")] | length')
warning_semantic_count=$(echo "$build_json" | jq '[.warnings[] | select(.issueType == "Semantic Issue")] | length')

# Destination info
destination_os_version=$(echo "$build_json" | jq -r '.destination.osVersion // "unknown"')
destination_device=$(echo "$build_json" | jq -r '.destination.modelName // "unknown"')
destination_platform=$(echo "$build_json" | jq -r '.destination.platform // "unknown"')

echo "Extracting test results from $XCRESULT_PATH..."
test_json=$(xcrun xcresulttool get test-results --path "$XCRESULT_PATH" --format json 2>/dev/null || echo '{}')

if [[ "$test_json" != "{}" ]]; then
  # Test counts - handle nested structure
  test_count_total=$(echo "$test_json" | jq '[.testNodes[].children[]?.children[]?.children[]? | select(.nodeType == "Test Case")] | length')
  test_count_passed=$(echo "$test_json" | jq '[.testNodes[].children[]?.children[]?.children[]? | select(.nodeType == "Test Case" and .result == "Passed")] | length')
  test_count_failed=$(echo "$test_json" | jq '[.testNodes[].children[]?.children[]?.children[]? | select(.nodeType == "Test Case" and .result == "Failed")] | length')
  test_count_skipped=$(echo "$test_json" | jq '[.testNodes[].children[]?.children[]?.children[]? | select(.nodeType == "Test Case" and .result == "Skipped")] | length')

  # Test pass rate (as percentage, avoid division by zero)
  if [[ "$test_count_total" -gt 0 ]]; then
    test_pass_rate=$(echo "scale=2; $test_count_passed * 100 / $test_count_total" | bc)
  else
    test_pass_rate="0"
  fi

  # Test duration (sum of all test durations in ms)
  test_duration_total_ms=$(echo "$test_json" | jq '([.testNodes[].children[]?.children[]?.children[]?.durationInSeconds? // 0] | add) * 1000 | round')

  # Test suite count
  test_suite_count=$(echo "$test_json" | jq '[.testNodes[].children[]?.children[]? | select(.nodeType == "Test Suite")] | length')

  # Slowest test
  slowest_test=$(echo "$test_json" | jq -r '[.testNodes[].children[]?.children[]?.children[]? | select(.nodeType == "Test Case")] | sort_by(-.durationInSeconds) | .[0] // {}')
  test_slowest_name=$(echo "$slowest_test" | jq -r '.name // "none"')
  test_slowest_duration_ms=$(echo "$slowest_test" | jq '((.durationInSeconds // 0) * 1000) | round')
else
  echo "No test results found, skipping test metrics."
  test_count_total=0
  test_count_passed=0
  test_count_failed=0
  test_count_skipped=0
  test_pass_rate="0"
  test_duration_total_ms=0
  test_suite_count=0
  test_slowest_name="none"
  test_slowest_duration_ms=0
fi

payload=$(jq -n \
  --arg prefix "$PREFIX" \
  --arg user "$USER_NAME" \
  --arg project "$PROJECT" \
  --arg environment "$ENVIRONMENT" \
  --arg architecture "$ARCHITECTURE" \
  --arg os "$OPERATING_SYSTEM" \
  --arg branch "$BRANCH" \
  --arg action_title "$action_title" \
  --argjson analyzer_warning_count "$analyzer_warning_count" \
  --argjson end_time "$end_time" \
  --argjson error_count "$error_count" \
  --argjson start_time "$start_time" \
  --arg status "$status" \
  --argjson warning_count "$warning_count" \
  --argjson build_time "$build_time" \
  --argjson warning_deprecation_count "$warning_deprecation_count" \
  --argjson warning_preprocessor_count "$warning_preprocessor_count" \
  --argjson warning_swift_compiler_count "$warning_swift_compiler_count" \
  --argjson warning_semantic_count "$warning_semantic_count" \
  --arg destination_os_version "$destination_os_version" \
  --arg destination_device "$destination_device" \
  --arg destination_platform "$destination_platform" \
  --argjson test_count_total "$test_count_total" \
  --argjson test_count_passed "$test_count_passed" \
  --argjson test_count_failed "$test_count_failed" \
  --argjson test_count_skipped "$test_count_skipped" \
  --arg test_pass_rate "$test_pass_rate" \
  --argjson test_duration_total_ms "$test_duration_total_ms" \
  --argjson test_suite_count "$test_suite_count" \
  --arg test_slowest_name "$test_slowest_name" \
  --argjson test_slowest_duration_ms "$test_slowest_duration_ms" \
  '{
    meta: [
      { name: ($prefix + "-user"),             value: $user },
      { name: ($prefix + "-project"),          value: $project },
      { name: ($prefix + "-environment"),      value: $environment },
      { name: ($prefix + "-architecture"),     value: $architecture },
      { name: ($prefix + "-operating-system"), value: $os },
      { name: ($prefix + "-metrics-source"),   value: "grouped-metrics" },
      { name: ($prefix + "-branch"),           value: $branch }
    ],
    metrics: [
      { name: ($prefix + "-action-title"),           value: $action_title },
      { name: ($prefix + "-analyzer-warning-count"), value: ($analyzer_warning_count | tostring) },
      { name: ($prefix + "-error-count"),            value: ($error_count | tostring) },
      { name: ($prefix + "-status"),                 value: $status },
      { name: ($prefix + "-warning-count"),          value: ($warning_count | tostring) },
      { name: ($prefix + "-build-time"),             value: ($build_time | tostring) },
      { name: ($prefix + "-warning-deprecation-count"),     value: ($warning_deprecation_count | tostring) },
      { name: ($prefix + "-warning-preprocessor-count"),    value: ($warning_preprocessor_count | tostring) },
      { name: ($prefix + "-warning-swift-compiler-count"),  value: ($warning_swift_compiler_count | tostring) },
      { name: ($prefix + "-warning-semantic-count"),        value: ($warning_semantic_count | tostring) },
      { name: ($prefix + "-destination-os-version"), value: $destination_os_version },
      { name: ($prefix + "-destination-device"),     value: $destination_device },
      { name: ($prefix + "-destination-platform"),   value: $destination_platform },
      { name: ($prefix + "-test-count-total"),       value: ($test_count_total | tostring) },
      { name: ($prefix + "-test-count-passed"),      value: ($test_count_passed | tostring) },
      { name: ($prefix + "-test-count-failed"),      value: ($test_count_failed | tostring) },
      { name: ($prefix + "-test-count-skipped"),     value: ($test_count_skipped | tostring) },
      { name: ($prefix + "-test-pass-rate"),         value: $test_pass_rate },
      { name: ($prefix + "-test-duration-total-ms"), value: ($test_duration_total_ms | tostring) },
      { name: ($prefix + "-test-suite-count"),       value: ($test_suite_count | tostring) },
      { name: ($prefix + "-test-slowest-name"),      value: $test_slowest_name },
      { name: ($prefix + "-test-slowest-duration-ms"), value: ($test_slowest_duration_ms | tostring) }
    ]
  }'
)

echo "Will attempt to upload the following JSON:"
echo "$payload" | jq .

if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Skipping POST to $METRICS_URL"
  exit 0
fi

response=$(curl -s -w "\n%{http_code}" -X POST "$METRICS_URL" \
  -H "Accept: application/json" \
  -H "Accept-Charset: UTF-8" \
  -H "Authorization: Bearer $TOKEN" \
  -H "User-Agent: Xcode/xcresulttool" \
  -H "Content-Type: application/json" \
  -d "$payload")

# Extract body and status code
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "POST $METRICS_URL -> $http_code"
echo "$body"

if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
  exit 0
else
  exit 1
fi
