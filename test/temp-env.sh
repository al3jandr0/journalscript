#!/bin/bash
TEST_ROOT_DIR=$(mktemp -d)

if [[ ! "$TEST_ROOT_DIR" || ! -d "$TEST_ROOT_DIR" ]]; then
  echo "Could not create test root dir"
  exit 1
fi

cleanup() {
    rm -rf "$TEST_ROOT_DIR" 
}

# TODO: come up with a bash independent way to trap
trap cleanup EXIT 

## Populate test directory with basic structure
mkdir -p "$TEST_ROOT_DIR/home/$USER"
mkdir -p "$TEST_ROOT_DIR/home/$USER/.config"
mkdir -p "$TEST_ROOT_DIR/home/$USER/.bin"
mkdir -p "$TEST_ROOT_DIR/home/$USER/.cache"
mkdir -p "$TEST_ROOT_DIR/home/$USER/.local/share"
mkdir -p "$TEST_ROOT_DIR/home/$USER/.local/state"
mkdir -p "$TEST_ROOT_DIR/home/$USER/Documents"
mkdir -p "$TEST_ROOT_DIR/tmp"
mkdir -p "$TEST_ROOT_DIR/bin"
mkdir -p "$TEST_ROOT_DIR/dev"
mkdir -p "$TEST_ROOT_DIR/etc"
mkdir -p "$TEST_ROOT_DIR/lib"
mkdir -p "$TEST_ROOT_DIR/sbin"
mkdir -p "$TEST_ROOT_DIR/var"
mkdir -p "$TEST_ROOT_DIR/var/log"
mkdir -p "$TEST_ROOT_DIR/var/lock"
mkdir -p "$TEST_ROOT_DIR/var/tmp"
mkdir -p "$TEST_ROOT_DIR/usr"
mkdir -p "$TEST_ROOT_DIR/usr/bin"
mkdir -p "$TEST_ROOT_DIR/usr/man"
mkdir -p "$TEST_ROOT_DIR/usr/lib"
mkdir -p "$TEST_ROOT_DIR/usr/local"
mkdir -p "$TEST_ROOT_DIR/usr/share"
mkdir -p "$TEST_ROOT_DIR/mnt"
mkdir -p "$TEST_ROOT_DIR/proc"

## Vars to override for a clean environment
# run tests
HOME="$TEST_ROOT_DIR/home/$USER"

JOURNAL_EXECUTABLE=$1

#### RUN TEST




