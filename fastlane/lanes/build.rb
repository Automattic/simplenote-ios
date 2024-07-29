# frozen_string_literal: true

desc 'Builds and uploads for distribution via App Store Connect'
lane :build_and_upload_to_app_store_connect do |options|
  unless options[:skip_prechecks]
    ios_build_prechecks(
      skip_confirm: options[:skip_confirm],
      external: true
    )
    ios_build_preflight
  end

  appstore_code_signing

  gym(
    scheme: 'Simplenote',
    workspace: 'Simplenote.xcworkspace',
    configuration: 'Distribution AppStore',
    clean: true,
    export_options: {
      method: 'app-store',
      export_team_id: TEAM_ID_APP_STORE_CONNECT,
      provisioningProfiles: simplenote_provisioning_profiles
    }
  )

  testflight(
    skip_waiting_for_build_processing: true,
    api_key_path: APP_STORE_CONNECT_KEY_PATH
  )

  sh('rm ../Simplenote.ipa')
  dsym_path = File.join(File.dirname(Dir.pwd), 'Simplenote.app.dSYM.zip')

  sentry_upload_dsym(
    dsym_path: dsym_path,
    auth_token: EnvManager.get_required_env!('SENTRY_AUTH_TOKEN'),
    org_slug: 'a8c',
    project_slug: 'simplenote-ios'
  )

  sh("rm #{dsym_path}")

  if options[:create_release]
    archive_zip_path = File.join(File.dirname(Dir.pwd), 'Simplenote.xarchive.zip')
    zip(path: lane_context[SharedValues::XCODEBUILD_ARCHIVE], output_path: archive_zip_path)

    version = options[:beta_release] ? ios_get_build_version : ios_get_app_version(public_version_xcconfig_file: VERSION_FILE_PATH)
    create_release(
      repository: GITHUB_REPO,
      version: version,
      release_notes_file_path: File.join(PROJECT_ROOT_FOLDER, 'Simplenote', 'Resources', 'release_notes.txt'),
      release_assets: archive_zip_path.to_s,
      prerelease: options[:beta_release]
    )

    sh("rm #{archive_zip_path}")
  end
end
