# CLAUDE.md

## Slow commands

`swift`, `xcodebuild`, and `fastlane` commands can take several minutes.
Account for this when setting `max_turns` on parallel subagents — 40 or higher is a safe default.

## Opening Pull Requests

Before opening a PR, read the `Dangerfile` and proactively satisfy its checks.
