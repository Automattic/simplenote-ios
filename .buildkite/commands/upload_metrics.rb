# frozen_string_literal: true

require 'json'
require 'time'
require 'open3'
require 'net/http'
require 'uri'
require 'shellwords'

PREFIX = 'simplenote-ios'

XCRESULT_PATH = ARGV[0] || 'build/results/Simplenote.xcresult'

# Hardcoded auth config (or set via ENV)
METRICS_URL   = ENV['METRICS_URL'] || 'https://metrics.a8c-ci.services/api/grouped-metrics'
TOKEN         = ENV['APPS_METRICS_UPLOAD_TOKEN']

META = [
  { name: 'simplenote-ios-user',             value: ENV['USER'] || ENV['USERNAME'] || 'unknown' },
  { name: 'simplenote-ios-project',          value: 'simplenote-ios' },
  { name: 'simplenote-ios-environment',      value: ENV['CI'] ? 'CI' : 'LOCAL' },
  { name: 'simplenote-ios-architecture',     value: `uname -m`.strip },
  { name: 'simplenote-ios-operating-system', value: `uname -s`.strip.downcase },
  { name: 'simplenote-ios-metrics-source',   value: 'grouped-metrics' }
].freeze

# ---------- HELPERS ----------
def run_cmd!(cmd)
  out, err, status = Open3.capture3(cmd)
  raise "Command failed (#{status.exitstatus}): #{cmd}\n#{err}" unless status.success?

  out
end

def to_epoch_ms(str_time)
  return nil if str_time.nil? || str_time.empty?

  (Time.parse(str_time).to_f * 1000).to_i
rescue
  nil
end

def dig_count(obj, *path)
  v = obj.dig(*path)
  return v.to_i if v.is_a?(Numeric) || v.is_a?(String)
  return v.length if v.is_a?(Array)

  0
end

raw_json = run_cmd!("xcrun xcresulttool get build-results --path #{Shellwords.escape(XCRESULT_PATH)} --format json")
data = JSON.parse(raw_json)

end_time = (data['endTime'] * 1_000).round(0)
start_time = (data['startTime'] * 1_000).round(0)

explicit_fields = {
  'action-title' => data['actionTitle'],
  'analyzer-warning-count' => data['analyzerWarningCount'],
  'end-time-unix-ms' => end_time,
  'error-count' => data['errorCount'],
  'start-time-unix-ms' => start_time,
  'status' => data['status'],
  'warning-count' => data['warningCount'],
  'build-time' => end_time - start_time
}

metrics_payload = explicit_fields.map do |k, v|
  { name: "#{PREFIX}-#{k}", value: v.to_s }
end

payload = {
  meta: META,
  metrics: metrics_payload
}

puts JSON.pretty_generate(payload)

uri = URI(METRICS_URL)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == 'https')

req = Net::HTTP::Post.new(uri.request_uri)
req['Accept'] = 'application/json'
req['Accept-Charset'] = 'UTF-8'
req['Authorization'] = "Bearer #{TOKEN}"
req['User-Agent'] = 'Xcode/xcresulttool'
req['Content-Type'] = 'application/json'
req.body = JSON.dump(payload)

res = http.request(req)

puts "POST #{METRICS_URL} -> #{res.code}"
puts res.body
exit(res.code.to_i.between?(200, 299) ? 0 : 1)
