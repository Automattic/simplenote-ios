# frozen_string_literal: true

# Validation only: default-deny around every fastlane action.
# Loaded unconditionally so that the lanes can't run live if the pre-command hook doesn't apply.
module ReleaseLaneGuard
  LOCAL_ACTIONS = %i[
    app_store_connect_api_key
    check_translation_progress
    ensure_git_branch
    ensure_git_status_clean
    git_add
    git_branch
    git_commit
    gp_downloadmetadata
    gp_update_metadata_source
    ios_download_strings_files_from_glotpress
    ios_generate_strings_file_from_code
    ios_lint_localizations
    is_ci
    setup_ci
  ].freeze

  EXPECTED_STOP = {
    complete_code_freeze: :push_to_git_remote,
    new_beta_release: :push_to_git_remote,
    finalize_release: :push_to_git_remote,
    publish_release: :publish_github_release,
    update_metadata_on_app_store_connect: :upload_to_app_store,
    upload_to_app_store_connect: :upload_to_testflight
  }.freeze

  FORBIDDEN_ENV = %w[CONFIGURE_ENCRYPTION_KEY GITHUB_TOKEN].freeze

  def execute(lane, platform = nil, parameters = nil)
    @guarded_lane ||= lane.to_sym
    super
  end

  def execute_action(method_sym, class_ref, arguments, custom_dir: nil, from_action: false)
    return super if LOCAL_ACTIONS.include?(method_sym)

    ReleaseLaneGuard.stop(lane: @guarded_lane, action: method_sym)
  end

  def self.stop(lane:, action:)
    leaked = FORBIDDEN_ENV.select { |key| ENV.key?(key) }
    fail_with("#{lane}: #{leaked.join(', ')} still set, so the hook did not apply", status: 4) unless leaked.empty?

    expected = EXPECTED_STOP[lane]
    fail_with("#{lane}: reached `#{action}`, expected `#{expected.inspect}`; not running it", status: 2) unless action == expected

    message = "RELEASE-LANE-GUARD PASS: `#{lane}` reached `#{action}` without decrypted secrets; not running it"
    puts message
    system('buildkite-agent', 'annotate', "#{message}\n", '--context', 'release-lane-guard', '--append') if ENV['BUILDKITE']
    $stdout.flush
    exit!(0)
  end

  def self.fail_with(message, status:)
    puts "RELEASE-LANE-GUARD FAIL: #{message}"
    $stdout.flush
    exit!(status)
  end
end

Fastlane::Runner.prepend(ReleaseLaneGuard)

# A lane that finishes without reaching its expected stop has not proved anything.
at_exit do
  ReleaseLaneGuard.fail_with('lane finished without reaching its expected stop', status: 3) if $!.nil? || ($!.is_a?(SystemExit) && $!.success?)
end
