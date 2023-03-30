#!/bin/env bash
#
# A helper script for checking versions on the CICD pipeline
# 
# This script computes 4 values, and it prints them in order
# 1) Gets the latest tagged, which indicates current release version
# 2) Gets the source's version
# 3) Whether the version is "new", "unchangened", or "unexpected"
# 4) Whether the version chnage (if any) correspondes to a MAJOR, MINRO
#    or PATCH release
#
# About tags and version number:
# The project uses semantic versioning.
#
# The latest release verions number is stored in the latest tag of master 
# branch
# The source of truth of journalscript's version is in the code itself
# run 'journal -v' to find out

# Inputs:
# optional first argument journalscript source file
SOURCE_FILE=${1:-"src/journal.sh"}

# Outputs:
LATEST_TAG=""       # vX.Y.Z
SOURCE_VERSION=""   # vX.Y.Z
VERSION_DIFF=""     # "NEW" | "UNCHANGED" | "UNEXPECTED"
CHANGE_TYPE=""      # "MAJOR" | "MINOR" | "PATCH" | ""

# Get the most recent commit accross all branches that has a tag
latest_tagged_commit=$(git rev-list --tags --max-count=1)
# Get the greates version number tag among the tags in the commit (a single
# commit could have multiple tags)
LATEST_TAG=$(git tag --list --points-at $latest_tagged_commit | sort -rV | head -1)
# If no tag (no releases have been done) default to version v0.0.0
LATEST_TAG=${LATEST_TAG:-"v0.0.0"}
#echo "latest_tag=$latest_tag"
#echo "tag=$latest_tag" >> "$GITHUB_OUTPUT"

# Get version and split the program name from the version number
SOURCE_VERSION=( $(bash $SOURCE_FILE -v) )
SOURCE_VERSION=${SOURCE_VERSION[1]}
#echo "current version=${v[1]}"
#echo "version=${v[1]}" >> "$GITHUB_OUTPUT"

larger=$(printf "v${SOURCE_VERSION}\n${LATEST_TAG}" | sort -rV | head -1)
if [[ "v${SOURCE_VERSION}" == "$LATEST_TAG" ]]; then
   VERSION_DIFF="UNCHANGED" 
elif [[ "v${SOURCE_VERSION}" == "$larger" ]]; then
    VERSION_DIFF="NEW"
else
    VERSION_DIFF="UNEXPECTED"
fi

# Removes 'v' prefix and splits the version components into an array
readarray -t -d "." tag < <(printf '%s' "${LATEST_TAG:1}")
readarray -t -d "." version < <(printf '%s' "$SOURCE_VERSION")

if [[ $VERSION_DIFF != "UNEXCPECTED" ]]; then
    if [[ "${tag[2]}" -ne "${version[2]}" ]]; then
        CHANGE_TYPE="PATCH"
    fi
    if [[ "${tag[1]}" -ne "${version[1]}" ]]; then
        CHANGE_TYPE="MINOR"
    fi
    if [[ "${tag[0]}" -ne "${version[0]}" ]]; then
        CHANGE_TYPE="MAJOR"
    fi
fi

printf "%s %s %s %s" "$LATEST_TAG" "v$SOURCE_VERSION" "$VERSION_DIFF" "$CHANGE_TYPE" 
