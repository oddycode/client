#! /usr/bin/env bash

set -e -u -o pipefail

here="$(dirname "$BASH_SOURCE")"
cd "$here"

npm i
make clean
make

# First let's get the index clean from other files that CI runs create.
git add -A ./ ../go/ ../shared/

# Protocol changes could create diffs in the following directories:
#   protocol/
#   go/
#   shared/
# This build process is idempotent. We expect there to be no changes after
# re-running the protocol generation, because any changes should have been
# checked in.

git diff HEAD -- ./ ../go/ ../shared/ # for testing
git diff --exit-code # for testing
echo $? # for testing

if ! git diff --quiet --exit-code HEAD -- ./ ../go/ ../shared/; then
  echo 'ERROR: `git diff` detected changes. The generated protocol files are stale.'
  exit 1
fi

echo 'SUCCESS: The generated protocol files are up to date.'
