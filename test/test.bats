################################################################################
# Test set for command: configure                                              # 
################################################################################

# TODO: add a tag for configure command such that you can filter tests per connand
# TODO: anchor to a specific bats version
# TODO: update scritp to handle whether directories have '/' at the end or not

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

_1=\
"1. When unsupported su-commands are provided to configure. "\
"Then journalscript exists with an error"
@test "${_1}" {
    run journal.sh configure invalid 
    assert_failure
}

###############################################################################
# Command: configure show                                                     #
###############################################################################

_1_1_1=\
"1.1.1 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command 'configure show' is invoked. "\
"Then journalscript should write the default configuration to stdout."
@test "${_1_1_1}" {
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

_1_1_1_dash_1=\
"1.1.1-1 Given no configuration file. "\
"And no env var overrides. "\
"And XDG 'dot' direcotory. "\
"And templates directory within config dir. "\
"When the command 'configure show' is invoked. "\
"Then journalscript should write the default configuration to stdout."
@test "${_1_1_1_dash_1}" {
    mkdir -p "$HOME/.config/journalscript/templates"
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/.config/journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.config/journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

_1_1_1_dash_2=\
"1.1.1-2 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"And templates directory within journals directory. "\
"When the command 'configure show' is invoked. "\
"Then journalscript should write the default configuration to stdout."
@test "${_1_1_1_dash_2}" {
    mkdir -p "$HOME/Documents/journals/.journalscript/templates"
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

_1_1_2=\
"1.1.2 Given the configuration file .journalscript.env located in $HOME/. "\
"And no env var overrides. "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_2}" {
    # setup
    mkdir -p "$HOME/.journalscript"
    cp "$BATS_TEST_DIRNAME/test-config-file.env" "$HOME/.journalscript/journalscript.env"
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"testType\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"testEditor\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"testJournal\""
}

_1_1_3=\
"1.1.3 Given the configuration file .journalscript.env located in $XDG_CONFIG/journalscript "\
"And no env var overrides. "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_3}" {
    # setup
    mkdir -p "$HOME/.config/journalscript"
    cp "$BATS_TEST_DIRNAME/test-config-file.env" "$HOME/.config/journalscript/journalscript.env"
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"testType\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"testEditor\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.config/journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"testJournal\""
}

_1_1_5=\
"1.1.5 Given no configuration file "\
"And all the configuration in env var overrides "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the overriden configuration to stdout."
@test "${_1_1_5}" {
    # setup
    export JOURNALSCRIPT_FILE_TYPE="madeupTestType"
    export JOURNALSCRIPT_EDITOR="madeupTestEditor"
    export JOURNALSCRIPT_DATA_DIR="$HOME/Documents/somewhere/journals"
    export JOURNALSCRIPT_TEMPLATE_DIR="$HOME/Documents/somewherelse/templates"
    export JOURNALSCRIPT_DEFAULT_JOURNAL="diary"

    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"$JOURNALSCRIPT_FILE_TYPE\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"$JOURNALSCRIPT_EDITOR\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$JOURNALSCRIPT_DATA_DIR\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$JOURNALSCRIPT_TEMPLATE_DIR\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"$JOURNALSCRIPT_DEFAULT_JOURNAL\""
}

_1_1_6=\
"1.1.6 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command 'configure' is invoked. "\
"Then journalscript runs configure show."
@test "${_1_1_6}" {
    run journal.sh configure
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

_1_1_7=\
"1.1.7 Given a configuration file with comments located in $HOME "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout ignoring the comments."
@test "${_1_1_7}" {
    # setup
    mkdir -p "$HOME/.journalscript"
    cp "$BATS_TEST_DIRNAME/test-config-file-with-comments.env" "$HOME/.journalscript/journalscript.env"
    run journal.sh configure show
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert output conforms to format
    _assert_output_conforms_to_format
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"testType\""
    refute_output --partial "Comments are ignored"
    # JOURNALSCRIPT_EDITOR is commented out from the file so the default (vi) should be provided
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
}


###############################################################################
# Command: configure init                                                     #
###############################################################################

_1_2_1=\
"1.2.1 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command configure init is invoked. "\
"And user inputs no values other than stdout for target file. "\
"And user accepts changes. "\
"Then journalscript writes to stdout default configuration values."
@test "${_1_2_1}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    TEMPLATE_DIR=""
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\nstdout\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    # TODO: update init behavior to create a tempalte directory in default location
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

_1_2_2=\
"1.2.2 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command configure init is invoked. "\
"And user inputs no values. "\
"And user accepts changes. "\
"Then journalscript writes default configuration values to config file in default location."
@test "${_1_2_2}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    TEMPLATE_DIR=""
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    FILE="$HOME/.journalscript/journalscript.env"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated configuration file  
    assert_exists "$FILE"
    assert_file_not_executable "$FILE"
    assert_file_owner "$USER" "$FILE"
    assert_file_contains "$FILE" "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

_1_2_3=\
"1.2.3 Given an existing configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command configure init is invoked. "\
"And user inputs no values. "\
"And user accepts changes. "\
"Then journalscript writes to configuration values to config file in default location."
@test "${_1_2_3}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    TEMPLATE_DIR=""
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    FILE="$HOME/.journalscript/journalscript.env"
    mkdir -p "$HOME/.journalscript"
    cp "$BATS_TEST_DIRNAME/test-config-file.env" "$FILE"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 

    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "$FILE will be overriden"
    # assert generated configuration file  
    assert_exists "$FILE"
    assert_file_not_executable "$FILE"
    assert_file_owner "$USER" "$FILE"
    # contents are defaulted to original configuration file if user specifies none
    assert_file_contains "$FILE" "JOURNALSCRIPT_FILE_TYPE=\"testType\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"testEditor\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

_1_2_4=\
"1.2.4 Given no configuration file. "\
"And no env var overrides. "\
"And XDG 'dot' direcotory. "\
"When the command configure init is invoked. "\
"And user inputs no values. "\
"And user accepts changes. "\
"Then journalscript writes to default configuration values to config file in xdg directory."
@test "${_1_2_4}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    TEMPLATE_DIR=""
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    FILE="$HOME/.config/journalscript/journalscript.env"
    mkdir -p "$HOME/.config/journalscript"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated configuration file  
    assert_exists "$FILE"
    assert_file_not_executable "$FILE"
    assert_file_owner "$USER" "$FILE"
    assert_file_contains "$FILE" "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"vi\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

_1_2_5=\
"1.2.5 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command configure init is invoked. "\
"And user provides inputs. "\
"And user accepts changes. "\
"Then journalscript writes a configuration file respecting the user choices."
@test "${_1_2_5}" {
    FILE_TYPE="banana"
    EDITOR="mango"
    DATA_DIR="$HOME"
    TEMPLATE_DIR="$HOME"
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    FILE="$HOME/.journalscript/journalscript.env"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated configuration file  
    assert_exists "$FILE"
    assert_file_not_executable "$FILE"
    assert_file_owner "$USER" "$FILE"
    assert_file_contains "$FILE" "JOURNALSCRIPT_FILE_TYPE=\"$FILE_TYPE\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"$EDITOR\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_DATA_DIR=\"$DATA_DIR\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$TEMPLATE_DIR\""
}

_1_2_6=\
"1.2.6 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When the command configure init is invoked. "\
"And user rejects changes. "\
"Then journalscript writes no configuration file."
@test "${_1_2_6}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    DEFAULT_JOURNAL=""
    TEMPLATE_DIR=""
    ACEPT_CHANGES="no"
    FILE="$HOME/.journalscript/journalscript.env"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated configuration file  
    assert_not_exists "$FILE"
    # chek other possible locations
    assert_not_exists "$HOME/.configure/journalscript/journalscript.env"
}

# TODO: test warnign and info messages. Im still workign out the language.
# TODO: add test for default journal

teardown() {
    unset _JOURNALSCRIPT_CONF_DIR
}

