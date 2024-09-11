# frozen_string_literal: true

PIPELINES_ROOT = 'release-pipelines'

platform :ios do
  lane :trigger_code_freeze_in_ci do
    buildkite_trigger_build(
      buildkite_organization: BUILDKITE_ORGANIZATION,
      buildkite_pipeline: BUILDKITE_PIPELINE,
      branch: DEFAULT_BRANCH,
      pipeline_file: File.join(PIPELINES_ROOT, 'start-code-freeze.yml'),
      message: 'Start Code Freeze'
    )
  end

  lane :trigger_complete_code_freeze_in_ci do |release_version: release_version_current|
    buildkite_trigger_build(
      buildkite_organization: BUILDKITE_ORGANIZATION,
      buildkite_pipeline: BUILDKITE_PIPELINE,
      branch: release_branch_name(release_version: release_version),
      pipeline_file: File.join(PIPELINES_ROOT, 'complete-code-freeze.yml'),
      message: "Complete code freeze for #{release_version}",
      environment: { RELEASE_VERSION: release_version }
    )
  end

  lane :trigger_new_beta_in_ci do |release_version: release_version_current|
    buildkite_trigger_build(
      buildkite_organization: BUILDKITE_ORGANIZATION,
      buildkite_pipeline: BUILDKITE_PIPELINE,
      branch: release_branch_name(release_version: release_version),
      pipeline_file: File.join(PIPELINES_ROOT, 'new-beta-release.yml'),
      message: "New beta for #{release_version}",
      environment: { RELEASE_VERSION: release_version }
    )
  end
end
