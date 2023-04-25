#!/bin/env bash
# Requires pandoc
# I decided to generate the manual before commits insteado if during CI such that
# the Homebrew formula wouldl have the manual available
pandoc --standalone --to=man --fail-if-warnings --output=journalscript.1 manpage.md
