# TODO: anchor to a specific bats version
setup() {
    # TODO: update with bats_load_library
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
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
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/.config"
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/.bin"
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/.cache"
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/.local/share"
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/.local/state"
    mkdir -p "$BATS_TEST_TMPDIR/home/$USER/Documents"
    mkdir -p "$BATS_TEST_TMPDIR/tmp"
    mkdir -p "$BATS_TEST_TMPDIR/bin"
    mkdir -p "$BATS_TEST_TMPDIR/dev"
    mkdir -p "$BATS_TEST_TMPDIR/etc"
    mkdir -p "$BATS_TEST_TMPDIR/lib"
    mkdir -p "$BATS_TEST_TMPDIR/sbin"
    mkdir -p "$BATS_TEST_TMPDIR/var"
    mkdir -p "$BATS_TEST_TMPDIR/var/log"
    mkdir -p "$BATS_TEST_TMPDIR/var/lock"
    mkdir -p "$BATS_TEST_TMPDIR/var/tmp"
    mkdir -p "$BATS_TEST_TMPDIR/usr"
    mkdir -p "$BATS_TEST_TMPDIR/usr/bin"
    mkdir -p "$BATS_TEST_TMPDIR/usr/man"
    mkdir -p "$BATS_TEST_TMPDIR/usr/lib"
    mkdir -p "$BATS_TEST_TMPDIR/usr/local"
    mkdir -p "$BATS_TEST_TMPDIR/usr/share"
    mkdir -p "$BATS_TEST_TMPDIR/mnt"
    mkdir -p "$BATS_TEST_TMPDIR/proc"

    HOME="$BATS_TEST_TMPDIR/home/$USER"
    # TODO: unset XDG_DOCUMENTS_DIR, XDG_CONFIG_HOME
}

#teardown() {
    #rm -rf "$BATS_TEST_TMPDIR" 
#}

###############################################################################
# 1. Test set for command: configure                                          #
###############################################################################

# TODO: add a tag for configure command such that you can filter tests per connand

# Format: <var_name>=["]<value>["]
# where var_name must be POSIX compliant
_assert_output_conforms_to_format() {
    for line in "${lines[@]}"; do
        assert_regex "$line" '^[a-zA-Z0-9][a-zA-Z0-9_]+="?.+"?$' 
    done
}

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
    assert_output --partial "JOURNALSCRIPT_DATA_DIR=\"$HOME/Documents\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/.journalscript/templates\""
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_NAME=\"journalscript.env\""
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
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_DIR=\"$HOME/.journalscript\""
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_NAME=\"journalscript.env\""
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
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_DIR=\"$HOME/.config/journalscript\""
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_NAME=\"journalscript.env\""
}

_1_1_4=\
"1.1.4 Given the configuration file .journalscript.env located in a custome directory "\
"And no env var overrides other than JOURNALSCRIPT_CONF_FILE_DIR "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_4}" {
    # setup
    export JOURNALSCRIPT_CONF_FILE_DIR="$HOME/Documents"
    cp "$BATS_TEST_DIRNAME/test-config-file.env" "$HOME/Documents/journalscript.env"
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
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_DIR=\"$HOME/Documents\""
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_NAME=\"journalscript.env\""
}

_1_1_5=\
"1.1.5 Given no configuration file "\
"And all the configuration in env var overrides "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_5}" {
    # setup
    export JOURNALSCRIPT_CONF_FILE_DIR="$HOME/Documents/somedir"
    export JOURNALSCRIPT_FILE_TYPE="madeupTestType"
    export JOURNALSCRIPT_EDITOR="madeupTestEditor"
    export JOURNALSCRIPT_DATA_DIR="$HOME/Documents/somewhere/journals"
    export JOURNALSCRIPT_TEMPLATE_DIR="$HOME/Documents/somewherelse/templates"
    export JOURNALSCRIPT_CONF_FILE_NAME="someFile.env"

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
    assert_output --partial "JOURNALSCRIPT_CONF_FILE_NAME=\"$JOURNALSCRIPT_CONF_FILE_NAME\""
}

teardown() {
    unset JOURNALSCRIPT_CONF_FILE_DIR
}

# TODO: test file loading ignores comments
#       test file loeading ignores vars that do not conforms to format
# TODO: update scritp to handle whether directories have '/' at the end or not


