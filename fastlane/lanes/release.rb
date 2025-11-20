# frozen_string_literal: true

# Lanes related to the Release Process (Code Freeze, Betas, Final Build, App Store Submission…)

platform :ios do
  # Creates a new release branch from the current default branch
  #
  # @param [String] version (optional) The version to use for the new release version to code freeze for.
  #                 Typically auto-provided by ReleasesV2. If nil, computes the new version based on current one.
  # @param [Boolean] skip_confirm (default: false) If set, will skip the confirmation prompt
  #
  lane :start_code_freeze do |version: nil, skip_confirm: false|
    ensure_git_status_clean

    Fastlane::Helper::GitHelper.checkout_and_pull(DEFAULT_BRANCH)

    # If a new version is passed, use it as source of truth from now on
    new_version = version || release_version_next
    computed_release_branch_name = release_branch_name(release_version: new_version)
    new_build_code = build_code_code_freeze(version_short: new_version)

    message = <<~MESSAGE
      Code Freeze:
      - New release branch from #{DEFAULT_BRANCH}: #{computed_release_branch_name}

      - Current release version and build code: #{release_version_current} (#{build_code_current}).
      - New release version and build code: #{new_version} (#{new_build_code}).
    MESSAGE

    UI.important(message)

    UI.user_error!('Aborted by user request') unless skip_confirm || UI.confirm('Do you want to continue?')

    ensure_branch_does_not_exist!(computed_release_branch_name)

    UI.message 'Creating release branch...'
    Fastlane::Helper::GitHelper.create_branch(computed_release_branch_name, from: DEFAULT_BRANCH)
    UI.success "Done! New release branch is: #{git_branch}"

    UI.message 'Bumping release version and build code...'
    PUBLIC_VERSION_FILE.write(
      version_short: new_version,
      version_long: new_build_code
    )
    UI.success "Done! New release version: #{release_version_current}. New build code: #{build_code_current}."

    commit_version_and_build_files

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

    next unless is_ci

    message = <<~MESSAGE
      Code freeze started successfully.

      Next steps:

      - Checkout `#{computed_release_branch_name}` branch locally
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

    create_backmerge_prs!
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
    # Uses build_code_current let user double-check result.
    UI.success "Done! Release version: #{release_version_current}. New build code: #{build_code_current}."

    UI.important('Pushing changes to remote and triggering the beta build...')
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    push_to_git_remote(tags: false)

    trigger_beta_build(branch_to_build: release_branch_name)

    create_backmerge_prs!
  end

  desc 'Trigger the final release build on CI'
  lane :finalize_release do |skip_confirm: false|
    UI.user_error!('Hotfix release detected. Please use `finalize_hotfix_release` instead.') if release_is_hotfix?

    ensure_git_status_clean
    ensure_git_branch_is_release_branch!

    check_translation_progress_all

    new_build_code = build_code_next
    version = release_version_current
    UI.important <<~MESSAGE
      Finalizing release #{version}:
      - Current build code: #{build_code_current}
      - Final build code: #{new_build_code}
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

    create_backmerge_prs!

    mark_github_release_milestone_as_completed(
      repository: GITHUB_REPO,
      release_version: version
    )
  end

  lane :publish_release do |skip_confirm: false|
    ensure_git_status_clean
    ensure_git_branch_is_release_branch!

    version_number = release_version_current

    current_branch = release_branch_name(release_version: version_number)
    next_release_branch = release_branch_name(release_version: release_version_next)

    UI.important <<~PROMPT
      Publish the #{version_number} release. This will:

      - Publish the existing draft `#{version_number}` release on GitHub
      - Which will also have GitHub create the associated Git tag, pointing to the tip of #{current_branch}
      - If the release branch for the next version `#{next_release_branch}` already exists, backmerge `#{current_branch}` into it
      - If needed, backmerge `#{current_branch}` back into `#{DEFAULT_BRANCH}`
      - Delete the `#{current_branch}` branch
    PROMPT
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    UI.important "Publishing release #{version_number} on GitHub..."

    publish_github_release(
      repository: GITHUB_REPO,
      name: version_number
    )

    create_backmerge_prs!

    # At this point, an intermediate branch has been created by creating a backmerge PR to a hotfix or the next version release branch.
    # This allows us to safely delete the `release/*` branch.
    # Note that if a hotfix or new release branches haven't been created, the backmerge PR would not have be created either.
    delete_remote_git_branch!(current_branch)
  end

  desc 'Creates a new hotfix branch for the given version:x.y.z. The branch will be cut from the tag x.y of the previous release'
  lane :new_hotfix_release do |version:, skip_confirm: false, skip_prechecks: false|
    ensure_git_status_clean unless skip_prechecks

    parsed_version = VERSION_FORMATTER.parse(version)
    # Validate that this is a hotfix version (must have a patch component > 0)
    UI.user_error!("Invalid hotfix version '#{version}'. Must include a patch number.") unless parsed_version.patch.to_i.positive?
    build_code_hotfix = BUILD_CODE_FORMATTER.build_code(version: parsed_version)
    previous_version = VERSION_FORMATTER.release_version(VERSION_CALCULATOR.previous_patch_version(version: parsed_version))
    previous_release_branch = release_branch_name(release_version: previous_version)

    # Determine the base for the hotfix branch: either a tag or a release branch
    base_ref_for_hotfix = if git_tag_exists(tag: previous_version, remote: true)
                            previous_version
                          elsif Fastlane::Helper::GitHelper.branch_exists_on_remote?(branch_name: previous_release_branch)
                            UI.message("ℹ️  Tag '#{previous_version}' not found on the remote. Using release branch '#{previous_release_branch}' as the base for hotfix instead.")
                            previous_release_branch
                          else
                            UI.user_error!("Neither tag '#{previous_version}' nor branch '#{previous_release_branch}' exists on the remote! A hotfix branch cannot be created.")
                          end

    message = <<~MESSAGE
      Hotfix release:
      - New hotfix version: #{version}
      - New build code: #{build_code_hotfix}
      - Branching from #{base_ref_for_hotfix}
    MESSAGE
    UI.important(message)

    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    UI.user_error!("Version '#{version}' already exists on the remote! Abort!") if git_tag_exists(tag: version, remote: true)

    # Fetch the base ref to ensure it's available locally
    sh('git', 'fetch', 'origin', base_ref_for_hotfix)

    UI.message("Creating hotfix branch from '#{base_ref_for_hotfix}'...")
    Fastlane::Helper::GitHelper.create_branch(
      release_branch_name(release_version: version),
      from: base_ref_for_hotfix
    )
    UI.success("Done! New hotfix branch is: '#{git_branch}'")

    UI.message('Bumping hotfix version and build code...')
    VERSION_FILE.write(
      version_short: version,
      version_long: build_code_hotfix
    )
    commit_version_bump

    unless skip_confirm || UI.confirm('Ready to push changes to remote?')
      UI.message("Terminating as requested. Don't forget to run the remainder of this automation manually.")
      next
    end

    push_to_git_remote(
      tags: false,
      set_upstream: is_ci == false # only set upstream when running locally, useless in transient CI builds
    )
  end

  desc 'Performs the final checks and triggers a release build for the hotfix in the current branch'
  lane :finalize_hotfix_release do |skip_confirm: true, skip_prechecks: false|
    unless skip_prechecks
      ensure_git_branch_is_release_branch!
      ensure_git_status_clean
    end

    hotfix_version = release_version_current

    UI.important("Will triggrer hotfix build for version #{hotfix_version}")
    UI.user_error!("Terminating as requested. Don't forget to run the remainder of this automation manually.") unless skip_confirm || UI.confirm('Do you want to continue?')

    trigger_release_build(branch_to_build: release_branch_name(release_version: hotfix_version))

    create_backmerge_prs!

    begin
      close_milestone(
        repository: GITHUB_REPO,
        milestone: hotfix_version
      )
    rescue StandardError => e
      report_milestone_error(error_title: "Error closing milestone `#{hotfix_version}`: #{e.message}")
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

def trigger_buildkite_release_build(branch:, beta:)
  environment = {
    BETA_RELEASE: beta,
    RELEASE_VERSION: release_version_current
  }
  pipeline_file_name = 'release-build.yml'

  # When in CI, upload the release build pipeline inline in the current pipeline.
  # Otherwise, trigger a build via the Buildkite APIs.
  if is_ci
    buildkite_pipeline_upload(
      pipeline_file: File.join(PROJECT_ROOT_FOLDER, '.buildkite', pipeline_file_name),
      # Both keys and values need to be passed as strings
      environment: environment.to_h { |k, v| [k.to_s, v.to_s] }
    )
  else
    build_url = buildkite_trigger_build(
      buildkite_organization: BUILDKITE_ORGANIZATION,
      buildkite_pipeline: BUILDKITE_PIPELINE,
      branch: branch,
      environment: environment,
      pipeline_file: pipeline_file_name
    )

    UI.success("Buildkite build triggered from branch #{branch}. Build URL: #{build_url}")
  end
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

def release_is_hotfix?
  VERSION_CALCULATOR.release_is_hotfix?(
    version: VERSION_FORMATTER.parse(PUBLIC_VERSION_FILE.read_release_version)
  )
end

def ensure_branch_does_not_exist!(branch_name)
  return unless Fastlane::Helper::GitHelper.branch_exists_on_remote?(branch_name: branch_name)

  error_message = "The branch `#{branch_name}` already exists. Please check first if there is an existing Pull Request that needs to be merged or closed first, " \
                  'or delete the branch to then run again the release task.'

  buildkite_annotate(style: 'error', context: 'error-checking-branch', message: error_message) if is_ci

  UI.user_error!(error_message)
end
