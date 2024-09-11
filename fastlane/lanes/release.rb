# frozen_string_literal: true

# Lanes related to the Release Process (Code Freeze, Betas, Final Build, App Store Submission…)

platform :ios do
  lane :code_freeze do |skip_confirm: false|
    ensure_git_status_clean

    Fastlane::Helper::GitHelper.checkout_and_pull(DEFAULT_BRANCH)

    computed_release_branch_name = release_branch_name(release_version: release_version_next)

    message = <<~MESSAGE
      Code Freeze:
      - New release branch from #{DEFAULT_BRANCH}: #{computed_release_branch_name}

      - Current release version and build code: #{release_version_current} (#{build_code_current}).
      - New release version and build code: #{release_version_next} (#{build_code_code_freeze}).
    MESSAGE

    UI.important(message)

    UI.user_error!('Aborted by user request') unless skip_confirm || UI.confirm('Do you want to continue?')

    UI.message 'Creating release branch...'
    Fastlane::Helper::GitHelper.create_branch(computed_release_branch_name, from: DEFAULT_BRANCH)
    UI.success "Done! New release branch is: #{git_branch}"

    UI.message 'Bumping release version and build code...'
    PUBLIC_VERSION_FILE.write(
      version_short: release_version_next,
      version_long: build_code_code_freeze
    )
    UI.success "Done! New release version: #{release_version_current}. New build code: #{build_code_current}."

    commit_version_and_build_files

    new_version = release_version_current

    # Delete all release notes metadata, including the source of truth.
    # We'll generate a new source of truth next, and the localized versions will be re-downloaded once translated on GlotPress.
    # It's important we delete them, otherwise we risk using old release notes for locales that won't get translated in time for the release finalization.
    delete_all_metadata_release_notes

    changelog_path = File.join(PROJECT_ROOT_FOLDER, 'RELEASE-NOTES.txt')
    extract_release_notes_for_version(
      version: new_version,
      release_notes_file_path: changelog_path,
      extracted_notes_file_path: RELEASE_NOTES_SOURCE_PATH
    )
    # Add a new section to the changelog for the version _after_ the one we are code freezing
    ios_update_release_notes(
      new_version: new_version,
      release_notes_file_path: changelog_path
    )

    UI.important('Pushing changes to remote, configuring the release on GitHub, and triggering the beta build...')
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    push_to_git_remote(
      tags: false,
      set_upstream: is_ci == false # only set upstream when running locally, useless in transient CI builds
    )

    copy_branch_protection(
      repository: GITHUB_REPO,
      from_branch: DEFAULT_BRANCH,
      to_branch: computed_release_branch_name
    )

    freeze_milestone_and_move_assigned_prs_to_next_milestone(
      milestone_to_freeze: new_version,
      next_milestone: release_version_next
    )

    check_pods_references

    next unless is_ci

    message = <<~MESSAGE
      Code freeze started successfully.

      Next steps:

      - Checkout `#{release_branch_name}` branch locally
      - Update Pods and release notes if needed
      - Finalize the code freeze
    MESSAGE
    buildkite_annotate(context: 'code-freeze-success', style: 'success', message: message)
  end

  lane :complete_code_freeze do |skip_confirm: false|
    ensure_git_branch_is_release_branch!
    ensure_git_status_clean

    version = release_version_current

    UI.important("Completing code freeze for: #{version}")

    UI.user_error!('Aborted by user request') unless skip_confirm || UI.confirm('Do you want to continue?')

    generate_strings_file_for_glotpress

    update_appstore_strings

    unless skip_confirm || UI.confirm('Ready to push changes to remote and trigger the beta build?')
      UI.message("Terminating as requested. Don't forget to run the remainder of this automation manually.")
      next
    end

    push_to_git_remote(tags: false)

    trigger_beta_build(branch_to_build: release_branch_name(release_version: version))

    pr_url = create_release_management_pull_request(
      release_version: version,
      base_branch: DEFAULT_BRANCH,
      title: "Merge #{version} code freeze"
    )

    next unless is_ci

    message = <<~MESSAGE
      Code freeze completed successfully. Next, review and merge the [integration PR](#{pr_url}).
    MESSAGE
    buildkite_annotate(context: 'code-freeze-completed', style: 'success', message: message)
  end

  lane :new_beta_release do |skip_confirm: false|
    ensure_git_status_clean
    ensure_git_branch_is_release_branch!

    new_build_code = build_code_next
    UI.important <<~MESSAGE
      New beta:
      - Current build code: #{build_code_current}
      - New build code: #{new_build_code}
    MESSAGE

    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    download_localized_strings_and_metadata_from_glotpress

    lint_localizations

    UI.message "Bumping build code to #{new_build_code}..."
    PUBLIC_VERSION_FILE.write(
      version_long: new_build_code
    )
    commit_version_and_build_files

    version = release_version_current
    # Uses build_code_current let user double-check result.
    UI.success "Done! Release version: #{version}. New build code: #{build_code_current}."

    UI.important('Pushing changes to remote and triggering the beta build...')
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    push_to_git_remote(tags: false)

    trigger_beta_build(branch_to_build: release_branch_name)

    pr_url = create_release_management_pull_request(
      release_version: version,
      base_branch: DEFAULT_BRANCH,
      title: "Merge #{new_build_code} beta"
    )

    next unless is_ci

    message = <<~MESSAGE
      New beta triggered successfully. Next, review and merge the [integration PR](#{pr_url}).
    MESSAGE
    buildkite_annotate(context: 'new-beta-completed', style: 'success', message: message)
  end

  desc 'Trigger the final release build on CI'
  lane :finalize_release do |skip_confirm: false|
    UI.user_error!('To finalize a hotfix, please use the finalize_hotfix_release lane instead') if ios_current_branch_is_hotfix

    ensure_git_status_clean
    ensure_git_branch_is_release_branch!

    check_translation_progress_all

    new_build_code = build_code_next
    version = release_version_current
    UI.important <<~MESSAGE
      Finalizing release #{version}:
      • Current build code: #{build_code_current}
      • Final build code: #{new_build_code}
    MESSAGE

    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    download_localized_strings_and_metadata_from_glotpress
    lint_localizations

    UI.message "Bumping build code to #{new_build_code}..."
    PUBLIC_VERSION_FILE.write(version_long: new_build_code)
    commit_version_and_build_files
    # Uses build_code_current let user double-check result.
    UI.success "Done! Release version: #{version}. Final build code: #{build_code_current}."

    UI.important('Will push changes to remote and trigger the release build.')
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    push_to_git_remote(tags: false)

    trigger_release_build(branch_to_build: release_branch_name)

    create_release_backmerge_pr(version_to_merge: version, next_version: release_version_next)

    remove_branch_protection(
      repository: GITHUB_REPO,
      branch: release_branch_name
    )

    begin
      set_milestone_frozen_marker(
        repository: GITHUB_REPO,
        milestone: version,
        freeze: false
      )

      create_new_milestone(repository: GITHUB_REPO)

      close_milestone(
        repository: GITHUB_REPO,
        milestone: version
      )
    rescue StandardError => e
      report_milestone_error(error_title: "Error in milestone finalization process for `#{version}`: #{e.message}")
    end
  end

  lane :trigger_beta_build do |branch_to_build:|
    trigger_buildkite_release_build(branch: branch_to_build, beta: true)
  end

  lane :trigger_release_build do |branch_to_build:|
    trigger_buildkite_release_build(branch: branch_to_build, beta: false)
  end
end

def commit_version_and_build_files
  git_commit(
    path: [VERSION_FILE_PATH],
    message: 'Bump version number',
    allow_nothing_to_commit: false
  )
end

def check_pods_references
  # This will also print the result to STDOUT
  result = ios_check_beta_deps(lockfile: File.join(PROJECT_ROOT_FOLDER, 'Podfile.lock'))

  style = result[:pods].nil? || result[:pods].empty? ? 'success' : 'warning'
  message = "### Checking Internal Dependencies are all on a **stable** version\n\n#{result[:message]}"
  buildkite_annotate(context: 'pods-check', style: style, message: message) if is_ci
end

def trigger_buildkite_release_build(branch:, beta:)
  build_url = buildkite_trigger_build(
    buildkite_organization: BUILDKITE_ORGANIZATION,
    buildkite_pipeline: BUILDKITE_PIPELINE,
    branch: branch,
    environment: { BETA_RELEASE: beta },
    pipeline_file: 'release-build.yml'
  )

  return unless is_ci

  message = "This build triggered #{build_url} on <code>#{branch}</code>."
  buildkite_annotate(style: 'info', context: 'trigger-release-build', message: message)
end

def create_release_backmerge_pr(version_to_merge:, next_version:)
  create_release_backmerge_pull_request(
    repository: GITHUB_REPO,
    source_branch: release_branch_name(release_version: version_to_merge),
    labels: ['Releases'],
    milestone_title: next_version
  )
rescue StandardError => e
  error_message = <<-MESSAGE
    Error creating backmerge pull request: #{e.message}
    If this is not the first time you are running the release task, the backmerge PR for the version `#{version_to_merge}` might have already been previously created.
    Please close any previous backmerge PR for `#{version_to_merge}`, delete the previous merge branch, then run the release task again.
  MESSAGE

  buildkite_annotate(style: 'error', context: 'error-creating-backmerge', message: error_message) if is_ci

  UI.user_error!(error_message)
end

def freeze_milestone_and_move_assigned_prs_to_next_milestone(
  milestone_to_freeze:,
  next_milestone:,
  github_repository: GITHUB_REPO
)
  # Notice that the order of execution is important here and should not be changed.
  #
  # First, we move the PR from milestone_to_freeze to next_milestone.
  # Then, we update milestone_to_freeze's tile with the frozen marker (traditionally ❄️ )
  #
  # If the order were to be reversed, the PRs lookup for milestone_to_freeze would yeld no value.
  # That's because the lookup uses the milestone title, which would no longer be milestone_to_freeze, but milestone_to_freeze + the frozen marker.
  begin
    # Move PRs to next milestone
    moved_prs = update_assigned_milestone(
      repository: github_repository,
      from_milestone: milestone_to_freeze,
      to_milestone: next_milestone,
      comment: "Version `#{milestone_to_freeze}` has entered code-freeze. The milestone of this PR has been updated to `#{next_milestone}`."
    )

    # Add ❄️ marker to milestone title to indicate we entered code-freeze
    set_milestone_frozen_marker(
      repository: github_repository,
      milestone: milestone_to_freeze
    )
  rescue StandardError => e
    moved_prs = []

    report_milestone_error(error_title: "Error during milestone `#{milestone_to_freeze}` freezing and PRs milestone updating process: #{e.message}")
  end

  UI.message("Moved the following PRs to milestone #{next_milestone}: #{moved_prs.join(', ')}")

  return unless is_ci

  moved_prs_info = if moved_prs.empty?
                     "No open PRs were targeting `#{milestone_to_freeze}` at the time of code-freeze."
                   else
                     "#{moved_prs.count} PRs targeting `#{milestone_to_freeze}` were still open at the time of code-freeze. They have been moved to `#{next_milestone}`:\n" \
                       + moved_prs.map { |pr_num| "[##{pr_num}](https://github.com/#{GITHUB_REPO}/pull/#{pr_num})" }.join(', ')
                   end

  buildkite_annotate(
    style: moved_prs.empty? ? 'success' : 'warning',
    context: 'code-freeze-milestone-updates',
    message: moved_prs_info
  )
end

def report_milestone_error(error_title:)
  error_message = <<-MESSAGE
    #{error_title}
    - If this is not the first time you are running the release task (e.g. retrying because it failed on first attempt), the milestone might have already been closed and this error is expected.
    - Otherwise, please investigate the error.
  MESSAGE

  UI.error(error_message)

  buildkite_annotate(style: 'warning', context: 'error-with-milestone', message: error_message) if is_ci
end

def delete_all_metadata_release_notes(store_metadata_folder: STORE_METADATA_FOLDER)
  files = Dir.glob(File.join(store_metadata_folder, '**', 'release_notes.txt'))
  files.each { |path| File.delete(path) }
  git_add(path: files)
  git_commit(
    path: files,
    message: 'Delete previous version release notes before code freeze',
    # Even if no locale was translated in the previous cycle, default/release_notes.txt should always be present, and therefore deleted at this stage.
    allow_nothing_to_commit: false
  )
end

def create_release_management_pull_request(
  release_version:,
  base_branch:,
  title:,
  use_integration_branch: true
)
  token = EnvManager.get_required_env!('GITHUB_TOKEN')

  if use_integration_branch
    Fastlane::Helper::GitHelper.create_branch(
      title.downcase.gsub(' ', '-'),
      from: git_branch
    )
  end

  pr_url = create_pull_request(
    api_token: token,
    repo: GITHUB_REPO,
    title: title,
    head: Fastlane::Helper::GitHelper.current_git_branch,
    base: base_branch,
    labels: 'Releases'
  )

  # Next, set the milestone for the PR
  #
  # The create_pull_request action has a 'milestone' parameter, but it expects the milestone id.
  # We don't know the id of the milestone, but we can use a different action to set it.
  #
  # PR URLs are in the format github.com/org/repo/pull/id
  pr_number = File.basename(pr_url)
  update_assigned_milestone(
    repository: GITHUB_REPO,
    numbers: [pr_number],
    to_milestone: release_version
  )

  # Return the PR URL
  pr_url
end
