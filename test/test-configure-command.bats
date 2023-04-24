################################################################################
# Test set for command: configure                                              # 
################################################################################

# timeout from any test after 2 seconds
BATS_TEST_TIMEOUT=2

setup() {
    load 'test_helper/common-setup'
    _common_setup
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
# bats file_tags=configure

_1=\
"1. When unsupported sub-commands are provided to configure. "\
"Then journalscript exits with an error"
@test "${_1}" {
    run journal.sh configure invalid 
    assert_failure
}

_1_dash_1=\
"1-1. When unsupported options are provided to configure init. "\
"Then journalscript exits with an error"
@test "${_1_dash_1}" {
    run journal.sh configure init --invalid 
    assert_failure
}

###############################################################################
# Command: configure show                                                     #
###############################################################################

# bats test_tags=configure:show
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
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

# bats test_tags=configure:show
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
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.config/journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.config/journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

# bats test_tags=configure:show
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
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

# bats test_tags=configure:show
_1_1_2=\
"1.1.2 Given the configuration file .journalscript.env located in $HOME/. "\
"And no env var overrides. "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_2}" {
    # setup
    mkdir -p "$HOME/.journalscript"
    cp "$BATS_TEST_DIRNAME/resources/config-file.env" "$HOME/.journalscript/journalscript.env"
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
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"testJournal\""
}

# bats test_tags=configure:show
_1_1_3=\
"1.1.3 Given the configuration file .journalscript.env located in \$XDG_CONFIG/journalscript "\
"And no env var overrides. "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout."
@test "${_1_1_3}" {
    # setup
    mkdir -p "$HOME/.config/journalscript"
    cp "$BATS_TEST_DIRNAME/resources/config-file.env" "$HOME/.config/journalscript/journalscript.env"
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
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.config/journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.config/journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"testJournal\""
}

# bats test_tags=configure:show
_1_1_5=\
"1.1.5 Given no configuration file "\
"And all the configuration in env var overrides "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the overriden configuration to stdout."
@test "${_1_1_5}" {
    # setup
    export JOURNALSCRIPT_FILE_TYPE="madeupTestType"
    export JOURNALSCRIPT_EDITOR="madeupTestEditor"
    export JOURNALSCRIPT_JOURNAL_DIR="$HOME/Documents/somewhere/journals"
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
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$JOURNALSCRIPT_JOURNAL_DIR\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$JOURNALSCRIPT_TEMPLATE_DIR\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"$JOURNALSCRIPT_DEFAULT_JOURNAL\""
}

# bats test_tags=configure:show
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
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.journalscript/hooks\""
    assert_output --partial "JOURNALSCRIPT_DEFAULT_JOURNAL=\"life\""
}

# bats test_tags=configure:show
_1_1_7=\
"1.1.7 Given a configuration file with comments located in $HOME "\
"And no env var overrides. "\
"And no XDG 'dot' direcotory "\
"When command 'configure show' is invoked. "\
"Then journalscript should write the file's configuration to stdout ignoring the comments."
@test "${_1_1_7}" {
    # setup
    mkdir -p "$HOME/.journalscript"
    cp "$BATS_TEST_DIRNAME/resources/config-file-comments.env" "$HOME/.journalscript/journalscript.env"
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
    # JOURNALSCRIPT_EDITOR is commented out from the file so the default (vim) should be provided
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
    assert_output --partial "_JOURNALSCRIPT_CONF_DIR=\"$HOME/.journalscript\""
    assert_output --partial "_JOURNALSCRIPT_HOOKS_DIR=\"$HOME/.journalscript/hooks\""
}


###############################################################################
# Command: configure init                                                     #
###############################################################################

# bats test_tags=configure:init
_1_2_1=\
"1.2.1 Given no configuration file. "\
"And no env var overrides. "\
"And no XDG 'dot' directory "\
"When the command configure init is invoked with the --print option. "\
"And user inputs no values. "\
"And user accepts changes. "\
"Then journalscript writes to stdout default configuration values."
@test "${_1_2_1}" {
    FILE_TYPE=""
    EDITOR=""
    DATA_DIR=""
    TEMPLATE_DIR=""
    DEFAULT_JOURNAL=""
    ACEPT_CHANGES="yes"
    run journal.sh configure init --print < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert configuration values are defaults
    assert_output --partial "JOURNALSCRIPT_FILE_TYPE=\"txt\""
    assert_output --partial "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    # TODO: update init behavior to create a tempalte directory in default location
    assert_output --partial "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

# bats test_tags=configure:init
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
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

# bats test_tags=configure:init
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
    cp "$BATS_TEST_DIRNAME/resources/config-file.env" "$FILE"
    run journal.sh configure init < <(printf "$FILE_TYPE\n$EDITOR\n$DATA_DIR\n$TEMPLATE_DIR\n$DEFAULT_JOURNAL\n\n$ACEPT_CHANGES") 

    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "The following files will be overriden"
    # assert generated configuration file  
    assert_exists "$FILE"
    assert_file_not_executable "$FILE"
    assert_file_owner "$USER" "$FILE"
    # contents are defaulted to original configuration file if user specifies none
    assert_file_contains "$FILE" "JOURNALSCRIPT_FILE_TYPE=\"testType\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"testEditor\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

# bats test_tags=configure:init
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
    assert_file_contains "$FILE" "JOURNALSCRIPT_EDITOR=\"vim\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_JOURNAL_DIR=\"$HOME/Documents/journals\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$HOME/Documents/journals/.journalscript/templates\""
}

# bats test_tags=configure:init
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
    assert_file_contains "$FILE" "JOURNALSCRIPT_JOURNAL_DIR=\"$DATA_DIR\""
    assert_file_contains "$FILE" "JOURNALSCRIPT_TEMPLATE_DIR=\"$TEMPLATE_DIR\""
}

# bats test_tags=configure:init
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

# TODO: add test for default journal

teardown() {
    unset _JOURNALSCRIPT_CONF_DIR
}

