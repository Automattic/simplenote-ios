#!/bin/bash -eu

# The Git command line client is not configured in Buildkite.
# At the moment, steps that need Git access can configure it on deman using this script.
# Later on, we should be able to configure it on the agent instead.
add_host_to_ssh_known_hosts github.com
git config --global user.email "mobile+wpmobilebot@automattic.com"
git config --global user.name "Automattic Release Bot"
