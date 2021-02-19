#!/bin/bash

#
# Runs SwiftLint on the whole workspace.
#
# This does not run in Continuous Integration.
#

# Abort if we are running in CI
# See https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables
if [ "$CI" = true ] ; then
  echo "warning: skipping SwiftLint build phase because running on CI."
  exit 0
fi

# Get the directory of this file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Temporarily move to the root directory so that SwiftLint can correctly
# find the paths returned from the `git` commands below.
pushd $DIR/../ > /dev/null

# Paths relative to the root directory
SWIFTLINT="./vendor/swiftlint/bin/swiftlint"
CONFIG_FILE=".swiftlint.yml"
if ! which $SWIFTLINT >/dev/null; then
  echo "error: SwiftLint is not installed. Install by running `rake dependencies`."
  exit 1
fi

# Run SwiftLint on the modified files.
#
# The `|| true` at the end is to stop `grep` from returning a non-zero exit if there
# are no matches. Xcode's build will fail if we don't do this.
#
MODIFIED_FILES=`git diff --name-only --diff-filter=d HEAD | grep -G "\.swift$" || true`
echo $MODIFIED_FILES | xargs $SWIFTLINT --config $CONFIG_FILE --quiet
MODIFIED_FILES_LINT_RESULT=$?

# Run SwiftLint on the added files
ADDED_FILES=`git ls-files --others --exclude-standard | grep -G "\.swift$" || true`
echo $ADDED_FILES | xargs $SWIFTLINT --config $CONFIG_FILE --quiet
ADDED_FILES_LINT_RESULT=$?

# Restore the previous directory
popd > /dev/null

# Exit with non-zero if SwiftLint found a serious violation in the linted files. 
#
# This stops Xcode from complaining about "...did not return a nonzero exit code...".
#
if [ $MODIFIED_FILES_LINT_RESULT -ne 0 ] || [ $ADDED_FILES_LINT_RESULT -ne 0 ] ; then 
  exit 1
fi
