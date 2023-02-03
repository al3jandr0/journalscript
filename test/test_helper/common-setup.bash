#!/usr/bin/env bash

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0, as those will
    # point to the bats executable's location or the preprocessed file 
    # respectively
    PROJECT_ROOT="$(
        cd "$( dirname "$BATS_TEST_FILENAME")"
        >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT/../src:$PATH"

    # Create "fake" file system directory structure
    # consider sharing the dir
    if [[ ! "$BATS_TEST_TMPDIR" || ! -d "$BATS_TEST_TMPDIR" ]]; then
      echo "Could not create test root dir"
      exit 1
    fi
    ## Populate test directory with basic structure
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER"
    mkdir "$BATS_TEST_TMPDIR/home/$USER/.config"
    mkdir "$BATS_TEST_TMPDIR/home/$USER/.bin"
    mkdir "$BATS_TEST_TMPDIR/home/$USER/.cache"
    mkdir "$BATS_TEST_TMPDIR/home/$USER/.local/"
    mkdir "$BATS_TEST_TMPDIR/home/$USER/Documents"
    mkdir "$BATS_TEST_TMPDIR/tmp"
    mkdir "$BATS_TEST_TMPDIR/bin"
    mkdir "$BATS_TEST_TMPDIR/dev"
    mkdir "$BATS_TEST_TMPDIR/etc"
    mkdir "$BATS_TEST_TMPDIR/lib"
    mkdir "$BATS_TEST_TMPDIR/sbin"
    mkdir "$BATS_TEST_TMPDIR/var"
    mkdir "$BATS_TEST_TMPDIR/usr"
    mkdir "$BATS_TEST_TMPDIR/usr/bin"
    mkdir "$BATS_TEST_TMPDIR/usr/man"
    mkdir "$BATS_TEST_TMPDIR/usr/lib"
    mkdir "$BATS_TEST_TMPDIR/usr/share"
    mkdir "$BATS_TEST_TMPDIR/mnt"
    mkdir "$BATS_TEST_TMPDIR/proc"

    HOME="$BATS_TEST_TMPDIR/home/$USER"
}
