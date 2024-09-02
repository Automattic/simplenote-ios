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
end
