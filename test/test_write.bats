################################################################################
# Test set for command: configure                                              # 
################################################################################

# TODO: add a tag for configure command such that you can filter tests per connand
# TODO: anchor to a specific bats version
# TODO: update scritp to handle whether directories have '/' at the end or not
# TODO: Set the variable $BATS_TEST_TIMEOUT before setup() starts. This means you can set it either on the command line, in free code in the test file or in setup_file().

setup() {
    # TODO: update with bats_load_library
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
    export JOURNALSCRIPT_EDITOR=":" # no-op editor
    # TODO: unset XDG_DOCUMENTS_DIR, XDG_CONFIG_HOME
}


# Format: <var_name>=["]<value>["]
# where var_name must be POSIX compliant(ish)
_assert_output_conforms_to_format() {
    for line in "${lines[@]}"; do
        assert_regex "$line" '^[a-zA-Z0-9_]+="?.+"?$' 
    done
}

###############################################################################
# Command: configure                                                          #
###############################################################################

_2=\
"2. When unsupported sub-commands are provided to write. "\
"Then journalscript exists with an error"
@test "${_2}" {
    run journal.sh myjournal banana 
    assert_failure
}

###############################################################################
# Command: write                                                              #
###############################################################################

_2_1_1=\
"2.1.1 Given no config file. "\
"And no env overrides. "\
"And no existing journal. "\
"When the command 'write' is invoked. "\
"Then journalscript should prompt the user to write a new journal dir with "\
"the default journal name at the default journal directory."
@test "${_2_1_1}" {
    run journal.sh < <(printf "y\n")
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal directory  
    assert_dir_exists "$HOME/Documents/journals/life"
}

_2_1_2=\
"2.1.2 Given no config file. "\
"And no env overrides. "\
"And no existing journal. "\
"When the command 'write myjournal' is invoked. "\
"Then journalscript should prompt the user to create a new journal dir with "\
"named 'myjournal' at the default journal directory."
@test "${_2_1_2}" {
    run journal.sh myjournal < <(printf "y\n")
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal directory  
    assert_dir_exists "$HOME/Documents/journals/myjournal"
}

_2_1_3=\
"2.1.3 Given no config file. "\
"And no env overrides. "\
"And no existing journal. "\
"When the command 'write' is invoked. "\
"Then journalscript should prompt the user to create a new journal dir with "\
"named 'myjournal' at the default journal directory. "\
"And a new entry is created in the journal directory with with the expected "\
" name format."
@test "${_2_1_3}" {
    run journal.sh < <(printf "y\n")
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    local todays_date=$(date +%Y-%m-%d)
    assert_file_exists "$HOME/Documents/journals/life/$todays_date.txt"
}

_2_1_4=\
"2.1.4 Given no config file. "\
"And no env overrides. "\
"And a existing journal with an exiting entry for today. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_1_4}" {
    mkdir -p "$HOME/Documents/journals/life"
    local todays_date=$(date +%Y-%m-%d)
    local file="$HOME/Documents/journals/life/$todays_date.txt"
    printf "Existing entry" > "$file"

    run journal.sh 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "^Existing entry$"
}

# 2.1.5 TODO: test permissions error

###############################################################################
# Command: write (with templates)                                             #
###############################################################################

_2_2_1=\
"2.2.1 Given no config file. "\
"And no env overrides. "\
"And no existing journal. "\
"When the command 'write' is invoked. "\
"Then journalscript should prompt the user to create a new journal dir with "\
"named 'myjournal' at the default journal directory. "\
"And a new entry is created in the journal directory with with the expected "\
"name format and with the default template as content. "
@test "${_2_2_1}" {
    local timestamp=$(date +'%a %b %d %I:%M %p %Z %Y')
    local todays_date=$(date +%Y-%m-%d)
    run journal.sh < <(printf "y\n")
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$HOME/Documents/journals/life/$todays_date.txt"
    assert_file_contains "$HOME/Documents/journals/life/$todays_date.txt" "$timestamp"
} 

# 2.2.2 Test default template is picked up at data directory
# 2.2.3 Test default template is picked up at configure directory
# 2.2.4 Test custom template is picked up at data directory
# 2.2.5 Test custom template is picked up at configure 

# TODO: provide VARS to hooks
# journal entry
# previous entry
# whether it is create or edit
# the journal directory


teardown() {
    unset JOURNALSCRIPT_DATA_DIR
}


























