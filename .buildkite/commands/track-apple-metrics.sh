#!/bin/bash

set -euo pipefail

METRICS_URL="${METRICS_URL:-https://metrics.a8c-ci.services/api/grouped-metrics}"

DRY_RUN=false
PREFIX=""
TOKEN="${APPS_METRICS_UPLOAD_TOKEN:-}"
XCRESULT_PATH=""
DERIVED_DATA_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    --token)
      TOKEN="$2"
      shift 2
      ;;
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

if [[ -z "$PREFIX" ]]; then
  echo "Error: --prefix is required" >&2
  exit 1
fi

if [[ -z "$XCRESULT_PATH" ]]; then
  echo "Error: --xcresult-path is required" >&2
  exit 1
fi

if [[ -z "$DERIVED_DATA_PATH" ]]; then
  echo "Error: --derived-data-path is required" >&2
  exit 1
fi

if [[ "$DRY_RUN" == false && -z "$TOKEN" ]]; then
  echo "Error: --token or APPS_METRICS_UPLOAD_TOKEN is required" >&2
  exit 1
fi

upload_artifact() {
  local path="$1"
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Skipping artifact upload: $path"
  else
    buildkite-agent artifact upload "$path"
  fi
}

echo "--- :xcode: Store raw xcresulttool JSONs"

mkdir -p build/xcresulttool

xcresulttool_build_results_path=build/xcresulttool/xcresulttool-build-results.json
xcrun xcresulttool get build-results \
  --path "$XCRESULT_PATH" \
  --format json > "$xcresulttool_build_results_path"
echo "Dumped xcresult build results to $xcresulttool_build_results_path"

upload_artifact "$xcresulttool_build_results_path"

xcresulttool_test_results_path=build/xcresulttool/xcresulttool-tests-results.json
xcrun xcresulttool get test-results tests \
  --path "$XCRESULT_PATH" \
  --format json > "$xcresulttool_test_results_path"
echo "Dumped xcresult test results to $xcresulttool_test_results_path"

upload_artifact "$xcresulttool_test_results_path"

echo "--- :coverage: Extract code coverage (if available)"

# Check if code coverage data is available in the xcresult bundle
coverage_availability=$(xcrun xcresulttool get content-availability --path "$XCRESULT_PATH" --compact)
has_coverage=$(echo "$coverage_availability" | jq -r '.hasCoverage // false')

if [[ "$has_coverage" == "true" ]]; then
  echo "Code coverage data found, extracting..."

  xccov_report_path=build/xcresulttool/xccov-report.json
  xcrun xccov view --report --json "$XCRESULT_PATH" > "$xccov_report_path"
  echo "Dumped code coverage report to $xccov_report_path"

  upload_artifact "$xccov_report_path"

  # Extract overall coverage percentage
  # xccov reports lineCoverage as a decimal (e.g., 0.4523 = 45.23%)
  coverage_line_percentage=$(jq '(.lineCoverage * 100) | round' "$xccov_report_path")

  echo "Line coverage: ${coverage_line_percentage}%"
else
  echo "No code coverage data available in xcresult bundle!"
  echo "To enable coverage, add 'code_coverage: true' to your Fastlane scan action,"
  echo "or pass '-enableCodeCoverage YES' to xcodebuild."

  coverage_line_percentage="n.a."
fi

echo "--- :xcode: Track XCLogParser report"

echo "~~~ Install XCLogParser"

brew install xclogparser

mkdir -p build/xclogparser-reports

echo "~~~ Dump xcactivitylog to JSON"

xclogparser dump \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --output build/xclogparser-reports/xcactivitylog-raw.json

upload_artifact "build/xclogparser-reports/xcactivitylog-raw.json"

echo "~~~ Generate JSON report"

xclogparser_json_path=build/xclogparser-reports/report.json
xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter json > "$xclogparser_json_path"

upload_artifact "$xclogparser_json_path"

echo "~~~ Generate Chrome tracer report"

xclogparser parse \
  --xcodeproj Simplenote.xcodeproj \
  --derived_data "$DERIVED_DATA_PATH" \
  --reporter chromeTracer > build/xclogparser-reports/build-trace.json

upload_artifact "build/xclogparser-reports/build-trace.json"

echo "--- :arrow_up: Upload to Apps Metrics"

# Metadata
USER_NAME="${USER:-${USERNAME:-unknown}}"
PROJECT="simplenote-ios"
ENVIRONMENT="${CI:+CI}"
ENVIRONMENT="${ENVIRONMENT:-LOCAL}"
ARCHITECTURE=$(uname -m)
OPERATING_SYSTEM=$(uname -s | tr '[:upper:]' '[:lower:]')
BRANCH="${BUILDKITE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

# Core build metrics
end_time=$(jq '(.endTime * 1000) | round' $xcresulttool_build_results_path)
start_time=$(jq '(.startTime * 1000) | round' $xcresulttool_build_results_path)
build_time=$((end_time - start_time))
action_title=$(jq -r '.actionTitle' $xcresulttool_build_results_path)
analyzer_warning_count=$(jq '.analyzerWarningCount' $xcresulttool_build_results_path)
error_count=$(jq '.errorCount' $xcresulttool_build_results_path)
status=$(jq -r '.status' $xcresulttool_build_results_path)
warning_count=$(jq '.warningCount' $xcresulttool_build_results_path)

# Warning breakdown by type
warning_deprecation_count=$(jq '[.warnings[] | select(.issueType == "DeprecatedDeclaration")] | length' $xcresulttool_build_results_path)
warning_preprocessor_count=$(jq '[.warnings[] | select(.issueType == "Lexical or Preprocessor Issue")] | length' $xcresulttool_build_results_path)
warning_swift_compiler_count=$(jq '[.warnings[] | select(.issueType == "Swift Compiler Warning")] | length' $xcresulttool_build_results_path)
warning_semantic_count=$(jq '[.warnings[] | select(.issueType == "Semantic Issue")] | length' $xcresulttool_build_results_path)

# Destination info
destination_os_version=$(jq -r '.destination.osVersion // "unknown"' $xcresulttool_build_results_path)
destination_device=$(jq -r '.destination.modelName // "unknown"' $xcresulttool_build_results_path)
destination_platform=$(jq -r '.destination.platform // "unknown"' $xcresulttool_build_results_path)

# Test counts - use recursive descent to handle variable nesting depth
test_count_total=$(jq '[.. | objects | select(.nodeType == "Test Case")] | length' $xcresulttool_test_results_path)
test_count_passed=$(jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Passed")] | length' $xcresulttool_test_results_path)
test_count_failed=$(jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Failed")] | length' $xcresulttool_test_results_path)
test_count_skipped=$(jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Skipped")] | length' $xcresulttool_test_results_path)

# Test pass rate (as percentage, avoid division by zero)
if [[ "$test_count_total" -gt 0 ]]; then
  test_pass_rate=$(echo "scale=2; $test_count_passed * 100 / $test_count_total" | bc)
else
  test_pass_rate="0"
fi

# Test duration (sum of all test durations in ms)
test_duration_total_ms=$(jq '([.. | objects | select(.nodeType == "Test Case") | .durationInSeconds // 0] | add) * 1000 | round' $xcresulttool_test_results_path)

# Test suite count
test_suite_count=$(jq '[.. | objects | select(.nodeType == "Test Suite")] | length' $xcresulttool_test_results_path)

# Slowest test
slowest_test=$(jq '[.. | objects | select(.nodeType == "Test Case")] | sort_by(-.durationInSeconds) | .[0] // {}' $xcresulttool_test_results_path)
test_slowest_name=$(echo "$slowest_test" | jq -r '.name // "none"')
test_slowest_duration_ms=$(echo "$slowest_test" | jq '((.durationInSeconds // 0) * 1000) | round')

# Per-target test metrics (dynamically extract for each test bundle)
# Convert target name to kebab-case for metric names (e.g., SimplenoteTests -> simplenote-tests)
to_kebab_case() {
  echo "$1" | sed 's/\([a-z]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]'
}

# Build metrics JSON array for all test bundles
per_target_metrics_json="[]"

# Get all test bundle names (both Unit and UI test bundles)
test_bundle_names=$(jq -r '[.. | objects | select(.nodeType == "Unit test bundle" or .nodeType == "UI test bundle") | .name] | .[]' $xcresulttool_test_results_path)

for bundle_name in $test_bundle_names; do
  echo "Extracting metrics for test target: $bundle_name"
  target_key=$(to_kebab_case "$bundle_name")

  # Extract the bundle object
  bundle_json=$(jq --arg name "$bundle_name" '[.. | objects | select((.nodeType == "Unit test bundle" or .nodeType == "UI test bundle") and .name == $name)][0]' $xcresulttool_test_results_path)

  # Extract metrics from the bundle
  target_count=$(echo "$bundle_json" | jq '[.. | objects | select(.nodeType == "Test Case")] | length')
  target_passed=$(echo "$bundle_json" | jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Passed")] | length')
  target_failed=$(echo "$bundle_json" | jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Failed")] | length')
  target_skipped=$(echo "$bundle_json" | jq '[.. | objects | select(.nodeType == "Test Case" and .result == "Skipped")] | length')
  target_duration_ms=$(echo "$bundle_json" | jq '([.. | objects | select(.nodeType == "Test Case") | .durationInSeconds // 0] | add) * 1000 | round')
  target_suite_count=$(echo "$bundle_json" | jq '[.. | objects | select(.nodeType == "Test Suite")] | length')

  if [[ "$target_count" -gt 0 ]]; then
    target_pass_rate=$(echo "scale=2; $target_passed * 100 / $target_count" | bc)
  else
    target_pass_rate="0"
  fi

  # Build metrics for this target and append to array
  target_metrics=$(jq -n \
    --arg prefix "$PREFIX" \
    --arg target "$target_key" \
    --arg count "$target_count" \
    --arg passed "$target_passed" \
    --arg failed "$target_failed" \
    --arg skipped "$target_skipped" \
    --arg pass_rate "$target_pass_rate" \
    --arg duration_ms "$target_duration_ms" \
    --arg suite_count "$target_suite_count" \
    '[
      { name: ($prefix + "-test-target-" + $target + "-count"), value: $count },
      { name: ($prefix + "-test-target-" + $target + "-count-passed"), value: $passed },
      { name: ($prefix + "-test-target-" + $target + "-count-failed"), value: $failed },
      { name: ($prefix + "-test-target-" + $target + "-count-skipped"), value: $skipped },
      { name: ($prefix + "-test-target-" + $target + "-pass-rate"), value: $pass_rate },
      { name: ($prefix + "-test-target-" + $target + "-duration-ms"), value: $duration_ms },
      { name: ($prefix + "-test-target-" + $target + "-suite-count"), value: $suite_count }
    ]')

  per_target_metrics_json=$(echo "$per_target_metrics_json" "$target_metrics" | jq -s 'add')
done

echo "Found $(echo "$per_target_metrics_json" | jq 'length') per-target metrics"

echo "Extracting xclogparser metrics from $xclogparser_json_path..."
xlp_json=$(cat "$xclogparser_json_path")

compilation_duration_ms=$(echo "$xlp_json" | jq '(.compilationDuration * 1000) | round')
target_count=$(echo "$xlp_json" | jq '[.subSteps[] | select(.title | startswith("Build target"))] | length')
cached_step_count=$(echo "$xlp_json" | jq '[.subSteps[] | select(.fetchedFromCache == true)] | length')
total_step_count=$(echo "$xlp_json" | jq '.subSteps | length')

if [[ "$total_step_count" -gt 0 ]]; then
  cache_hit_rate=$(echo "scale=1; $cached_step_count * 100 / $total_step_count" | bc)
else
  cache_hit_rate="0"
fi

slowest_target=$(echo "$xlp_json" | jq '[.subSteps[] | select(.title | startswith("Build target"))] | sort_by(-.duration) | .[0] // {}')
slowest_target_name=$(echo "$slowest_target" | jq -r '.title // "none"')
slowest_target_duration_ms=$(echo "$slowest_target" | jq '((.duration // 0) * 1000) | round')

# Per-build-target metrics
per_build_target_metrics_json="[]"

# Get all build target names (strip "Build target " prefix in jq)
# Use process substitution to iterate reliably across different shell environments
while IFS= read -r target_name; do
  [[ -z "$target_name" ]] && continue

  echo "Extracting metrics for build target: $target_name"
  target_key=$(to_kebab_case "$target_name")

  # Extract metrics for this target (reconstruct full title for matching)
  target_json=$(jq --arg title "Build target $target_name" '.subSteps[] | select(.title == $title)' "$xclogparser_json_path")

  target_duration_ms=$(echo "$target_json" | jq '((.duration // 0) * 1000) | round')
  target_warning_count=$(echo "$target_json" | jq '.warningCount // 0')
  target_error_count=$(echo "$target_json" | jq '.errorCount // 0')
  target_cached=$(echo "$target_json" | jq -r 'if .fetchedFromCache then "true" else "false" end')

  # Build metrics for this target and append to array
  build_target_metrics=$(jq -n \
    --arg prefix "$PREFIX" \
    --arg target "$target_key" \
    --arg duration_ms "$target_duration_ms" \
    --arg warning_count "$target_warning_count" \
    --arg error_count "$target_error_count" \
    --arg cached "$target_cached" \
    '[
      { name: ($prefix + "-build-target-" + $target + "-duration-ms"), value: $duration_ms },
      { name: ($prefix + "-build-target-" + $target + "-warning-count"), value: $warning_count },
      { name: ($prefix + "-build-target-" + $target + "-error-count"), value: $error_count },
      { name: ($prefix + "-build-target-" + $target + "-cached"), value: $cached }
    ]')

  per_build_target_metrics_json=$(echo "$per_build_target_metrics_json" "$build_target_metrics" | jq -s 'add')
done < <(jq -r '[.subSteps[] | select(.title | startswith("Build target")) | .title | sub("^Build target "; "")] | .[]' "$xclogparser_json_path")

echo "Found $(echo "$per_build_target_metrics_json" | jq 'length') per-build-target metrics"

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
  --argjson per_target_metrics "$per_target_metrics_json" \
  --argjson compilation_duration_ms "$compilation_duration_ms" \
  --argjson target_count "$target_count" \
  --argjson cached_step_count "$cached_step_count" \
  --arg cache_hit_rate "$cache_hit_rate" \
  --arg slowest_target_name "$slowest_target_name" \
  --argjson slowest_target_duration_ms "$slowest_target_duration_ms" \
  --arg coverage_line_percentage "$coverage_line_percentage" \
  --argjson per_build_target_metrics "$per_build_target_metrics_json" \
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
    metrics: ([
      { name: ($prefix + "-analyzer-warning-count"), value: ($analyzer_warning_count | tostring) },
      { name: ($prefix + "-error-count"),            value: ($error_count | tostring) },
      { name: ($prefix + "-status"),                 value: $status },
      { name: ($prefix + "-warning-count-total"),    value: ($warning_count | tostring) },
      { name: ($prefix + "-build-time"),             value: ($build_time | tostring) },
      { name: ($prefix + "-warning-deprecation-count"),     value: ($warning_deprecation_count | tostring) },
      { name: ($prefix + "-warning-preprocessor-count"),    value: ($warning_preprocessor_count | tostring) },
      { name: ($prefix + "-warning-swift-compiler-count"),  value: ($warning_swift_compiler_count | tostring) },
      { name: ($prefix + "-warning-semantic-count"),        value: ($warning_semantic_count | tostring) },
      { name: ($prefix + "-test-total-count"),       value: ($test_count_total | tostring) },
      { name: ($prefix + "-test-total-count-passed"),      value: ($test_count_passed | tostring) },
      { name: ($prefix + "-test-total-count-failed"),      value: ($test_count_failed | tostring) },
      { name: ($prefix + "-test-total-count-skipped"),     value: ($test_count_skipped | tostring) },
      { name: ($prefix + "-test-total-pass-rate"),         value: $test_pass_rate },
      { name: ($prefix + "-test-total-duration-ms"), value: ($test_duration_total_ms | tostring) },
      { name: ($prefix + "-test-total-suite-count"),       value: ($test_suite_count | tostring) },
      { name: ($prefix + "-test-slowest-name"),      value: $test_slowest_name },
      { name: ($prefix + "-test-slowest-duration-ms"), value: ($test_slowest_duration_ms | tostring) },
      { name: ($prefix + "-compilation-duration-ms"),  value: ($compilation_duration_ms | tostring) },
      { name: ($prefix + "-target-count"),             value: ($target_count | tostring) },
      { name: ($prefix + "-cached-step-count"),        value: ($cached_step_count | tostring) },
      { name: ($prefix + "-cache-hit-rate"),           value: $cache_hit_rate },
      { name: ($prefix + "-slowest-target-name"),      value: $slowest_target_name },
      { name: ($prefix + "-slowest-target-duration-ms"), value: ($slowest_target_duration_ms | tostring) },
      { name: ($prefix + "-test-total-coverage-line-percentage"), value: $coverage_line_percentage }
    ] + $per_target_metrics + $per_build_target_metrics)
  }'
)

apps_metrics_path="build/apps-metrics-payload.json"
echo "$payload" | jq . > "$apps_metrics_path"
echo "Will attempt to post the following metrics (saved to $apps_metrics_path):"
cat "$apps_metrics_path"

upload_artifact "$apps_metrics_path"

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
