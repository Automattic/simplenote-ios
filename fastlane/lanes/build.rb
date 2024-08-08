# frozen_string_literal: true

APP_STORE_CONNECT_OUTPUT_NAME = 'Simplenote-AppStore'

desc 'Builds and uploads for distribution via App Store Connect'
lane :build_and_upload_to_app_store_connect do |beta_release:, skip_prechecks: false, skip_confirm: false, create_release: false|
  unless skip_prechecks
    ensure_git_status_clean unless skip_prechecks || is_ci
    sentry_check_cli_installed
  end

  UI.important("Building version #{release_version_current} (#{build_code_current}) and uploading to TestFlight...")
  UI.user_error!('Aborted by user request') unless skip_confirm || UI.confirm('Do you want to continue?')

  build_for_app_store_connect

  upload_to_app_store_connect(
    beta_release: beta_release,
    skip_prechecks: skip_prechecks,
    create_release: create_release
  )
end

lane :build_for_app_store_connect do |fetch_code_signing: true|
  appstore_code_signing if fetch_code_signing

  build_app(
    scheme: 'Simplenote',
    workspace: WORKSPACE,
    configuration: 'Distribution AppStore',
    clean: true,
    export_method: 'app-store',
    # "build" is where the xcarchive will go, "output" where the ipa and dSYM will go.
    # We need to define both to have predictable artifact paths to use in other lanes and automation.
    build_path: OUTPUT_DIRECTORY_PATH,
    output_directory: OUTPUT_DIRECTORY_PATH,
    output_name: APP_STORE_CONNECT_OUTPUT_NAME
  )
end

lane :upload_to_app_store_connect do |beta_release:, skip_prechecks: false, create_release: false|
  sentry_check_cli_installed unless skip_prechecks

  ipa_path = File.join(OUTPUT_DIRECTORY_PATH, "#{APP_STORE_CONNECT_OUTPUT_NAME}.ipa")
  UI.user_error!("Could not find ipa at #{ipa_path}!") unless File.exist?(ipa_path)

  dsym_path = File.join(OUTPUT_DIRECTORY_PATH, "#{APP_STORE_CONNECT_OUTPUT_NAME}.app.dSYM.zip")
  UI.user_error!("Could not find dSYM at #{dsym_path}!") unless File.exist?(ipa_path)

  UI.important("Uploading ipa at #{ipa_path} to TestFlight...")
  testflight(
    ipa: ipa_path,
    skip_waiting_for_build_processing: true,
    api_key_path: APP_STORE_CONNECT_KEY_PATH
  )

  if File.exist?(dsym_path)
    UI.important("Uploading ipa at #{ipa_path} to TestFlight...")
  else
    UI.user_error!("Could not find ipa at #{ipa_path}!")
  end

  UI.important("Uploading dSYM at #{dsym_path} to Sentry...")
  sentry_upload_dsym(
    dsym_path: dsym_path,
    auth_token: EnvManager.get_required_env!('SENTRY_AUTH_TOKEN'),
    org_slug: 'a8c',
    project_slug: 'simplenote-ios'
  )

  next unless create_release

  archive_zip_path = File.join(OUTPUT_DIRECTORY_PATH, 'Simplenote.xarchive.zip')
  zip(path: lane_context[SharedValues::XCODEBUILD_ARCHIVE], output_path: archive_zip_path)

  # TODO: Use Versioning module to get the version
  version = beta_release ? ios_get_build_version : ios_get_app_version(public_version_xcconfig_file: VERSION_FILE_PATH)
  create_release(
    repository: GITHUB_REPO,
    version: version,
    release_notes_file_path: File.join(PROJECT_ROOT_FOLDER, 'Simplenote', 'Resources', 'release_notes.txt'),
    release_assets: archive_zip_path.to_s,
    prerelease: beta_release
  )
end
