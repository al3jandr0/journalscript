#!/bin/env bash
#
# A helper script for checking versions on the CICD pipeline
#
# This script computes 3 values, and it prints them in order
# 1) Gets the latest tagged, which indicates current release version
# 2) Gets the source's version
# 3) Whether the "commit" is a release(ture) or not(false)
#
# About tags and version number:
# - The project uses semantic versioning.
# - The latest release verions number is stored in the latest tag of master
#   branch
# - The source of truth of journalscript's version is in the code itself
#   run 'journal -v' to find out

set -e

###############################################################################
#  Inputs                                                                     #
###############################################################################
# optional first argument journalscript source file
SOURCE_FILE=${1:-"src/journal.sh"}

###############################################################################
#  Outputs
###############################################################################
LATEST_TAG=""      # vX.Y.Z
SOURCE_VERSION=-"" # vX.Y.Z
IS_RELEASE="false" # "true" | "false"

###############################################################################
#  Gets LATEST_TAG from git                                                   #
###############################################################################
# Get the most recent commit accross all branches that has a tag
latest_tagged_commit=$(git rev-list --tags --max-count=1)
# Get the greates version number tag among the tags in the commit (a single
# commit could have multiple tags)
LATEST_TAG=$(git tag --list --points-at $latest_tagged_commit | sort -rV | head -1)
# If no tag (no releases have been done) default to version v0.0.0
LATEST_TAG=${LATEST_TAG:-"v0.0.0"}
#echo "latest_tag=$latest_tag"

###############################################################################
#  Gets SOURCE_VERSION from the source code                                   #
###############################################################################
# Get version and split the program name from the version number
SOURCE_VERSION=($(bash $SOURCE_FILE -v))
SOURCE_VERSION="${SOURCE_VERSION[1]}"
#echo "current version=${v[1]}"

###############################################################################
#  Checks version numbers are valid and compute wether it is a relasse or not #
###############################################################################
larger=$(printf "v${SOURCE_VERSION}\n${LATEST_TAG}" | sort -rV | head -1)
if [[ "v${SOURCE_VERSION}" == "$LATEST_TAG" ]]; then
    IS_RELEASE="true"
elif [[ "v${SOURCE_VERSION}" == "$larger" ]]; then
    IS_RELEASE="false"
else
    printf "Unexpected version number. Source version (v%s) < latest tag (%s)\n" \
        "$SOURCE_VERSION" "$LATEST_TAG" >&2
fi

printf "%s %s %s" "$LATEST_TAG" "v$SOURCE_VERSION" "$IS_RELEASE"
