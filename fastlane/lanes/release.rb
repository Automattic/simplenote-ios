# frozen_string_literal: true

# Lanes related to the Release Process (Code Freeze, Betas, Final Build, App Store Submission…)

platform :ios do
  lane :code_freeze do |options|
    ios_codefreeze_prechecks(options)

    ios_bump_version_release
    new_version = ios_get_app_version(public_version_xcconfig_file: VERSION_FILE_PATH)

    extract_release_notes_for_version(
      version: new_version,
      release_notes_file_path: File.join(PROJECT_ROOT_FOLDER, 'RELEASE-NOTES.txt'),
      extracted_notes_file_path: File.join(PROJECT_ROOT_FOLDER, 'Simplenote', 'Resources', 'release_notes.txt')
    )
    ios_update_release_notes(new_version: new_version)

    generate_strings_file_for_glotpress

    UI.important('Pushing changes to remote, configuring the release on GitHub, and triggering the beta build')
    unless options[:skip_confirm] || UI.confirm('Do you want to continue?')
      UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.")
    end

    push_to_git_remote(tags: false)

    copy_branch_protection(
      repository: GITHUB_REPO,
      from_branch: DEFAULT_BRANCH,
      to_branch: "release/#{new_version}"
    )
    setfrozentag(
      repository: GITHUB_REPO,
      milestone: new_version
    )

    trigger_beta_build(branch_to_build: "release/#{new_version}")
  end

  lane :new_beta_release do |options|
    ios_betabuild_prechecks(options)
    download_localized_strings_and_metadata_from_glotpress
    ios_lint_localizations(
      input_dir: 'Simplenote',
      allow_retry: true
    )
    ios_bump_version_beta
    version = ios_get_app_version(public_version_xcconfig_file: VERSION_FILE_PATH)
    trigger_beta_build(branch_to_build: "release/#{version}")
  end

  lane :trigger_beta_build do |options|
    trigger_buildkite_release_build(
      branch: options[:branch_to_build],
      beta: true
    )
  end

  lane :trigger_release_build do |options|
    trigger_buildkite_release_build(
      branch: options[:branch_to_build],
      beta: false
    )
  end
end
