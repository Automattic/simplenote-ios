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

raw_json=$(xcrun xcresulttool get build-results --path "$XCRESULT_PATH" --format json)

end_time=$(echo "$raw_json" | jq '(.endTime * 1000) | round')
start_time=$(echo "$raw_json" | jq '(.startTime * 1000) | round')
build_time=$((end_time - start_time))
action_title=$(echo "$raw_json" | jq -r '.actionTitle')
analyzer_warning_count=$(echo "$raw_json" | jq '.analyzerWarningCount')
error_count=$(echo "$raw_json" | jq '.errorCount')
status=$(echo "$raw_json" | jq -r '.status')
warning_count=$(echo "$raw_json" | jq '.warningCount')

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
      { name: ($prefix + "-build-time"),             value: ($build_time | tostring) }
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
