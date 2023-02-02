################################################################################
# Test set for command: configure                                              # 
################################################################################

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

# 2.2.1 Test fallback behavior when there is no templates
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
_2_2_2=\
"2.2.2 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And default template exists in the journal dir. "\
"When the command 'write' is invoked. "\
"The contentes of the new template are copied into the new journal entry" 
@test "${_2_2_2}" {
    local template_dir="$HOME/Documents/journals/.journalscript/templates"
    mkdir -p "$template_dir"
    mkdir -p "$HOME/Documents/journals/life"
    printf "default template" > "$template_dir/template"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "default template"
}

# 2.2.3 Test default template is picked up at configure directory
_2_2_3=\
"2.2.3 Given no config file. "\
"And no env overrides. "\
"And no XDG dot dir. "\
"And existing journal. "\
"And default template exists in the config dir. "\
"When the command 'write' is invoked. "\
"The contentes of the new template are copied into the new journal entry" 
@test "${_2_2_3}" {
    local template_dir="$HOME/.journalscript/templates"
    mkdir -p "$template_dir"
    mkdir -p "$HOME/Documents/journals/life"
    printf "default template" > "$template_dir/template"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "default template"
}

# 2.2.4 Test custom template is picked up at data directory
_2_2_4=\
"2.2.4 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And default template exists in the journal dir. "\
"And default a matching journal specific template exists in the journal dir. "\
"When the command 'write' is invoked. "\
"The contents of the new template are copied into the new journal entry" 
@test "${_2_2_4}" {
    local template_dir="$HOME/Documents/journals/.journalscript/templates"
    mkdir -p "$template_dir"
    mkdir -p "$template_dir/template.d"
    mkdir -p "$HOME/Documents/journals/life"
    printf "default template" > "$template_dir/template"
    printf "custom template" > "$template_dir/template.d/life"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "custom template"
}

# 2.2.5 Test custom template is picked up at configure 
_2_2_5=\
"2.2.5 Given no config file. "\
"And no env overrides. "\
"And no XDG dot dir. "\
"And existing journal. "\
"And default template exists in the config dir. "\
"And default a matching journal specific template exists in the config dir. "\
"When the command 'write' is invoked. "\
"The contents of the new template are copied into the new journal entry" 
@test "${_2_2_5}" {
    local template_dir="$HOME/.config/journalscript/templates"
    mkdir -p "$template_dir"
    mkdir -p "$template_dir/template.d"
    mkdir -p "$HOME/Documents/journals/life"
    printf "default template" > "$template_dir/template"
    printf "custom template" > "$template_dir/template.d/life"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "custom template"
}

###############################################################################
# Command: write (with hooks)                                                 #
###############################################################################

# 2.3.1 Test fallback open hook behavior
_2_3_1=\
"2.3.1 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And no open hooks. "\
"When the command 'write' is invoked. "\
"Then journalscrip runs fallback 'hook'."
@test "${_2_3_1}" {
    mkdir -p "$HOME/Documents/journals/life"
    local todays_date=$(date +%Y-%m-%d)
    local todays_entry="$HOME/Documents/journals/life/$todays_date.txt"
    # A little hack to test whether fallback happens:
    # I cant set the EDITOR to a real editor because they are interactive
    # thus the test will hang
    # Instead I print to stdout. The 1st argument is the jounal entry file name
    # So by testing it is in the output, I ensure JOURNALSCRIPT_EDITOR was
    # invoked
    export JOURNALSCRIPT_EDITOR="echo"

    run journal.sh life
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "$todays_entry"
    # assert generated journal entry 
    assert_file_exists "$todays_entry"
}

# 2.3.2 Test default open hook
_2_3_2=\
"2.3.2 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And the default open hooks. "\
"When the command 'write' is invoked. "\
"Then journalscrip runs the default 'hook'."
@test "${_2_3_2}" {
    mkdir -p "$HOME/Documents/journals/life"
    mkdir -p "$HOME/.journalscript/hooks"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"
    printf 'echo "default open hook" > $JOURNALSCRIPT_JOURNAL_ENTRY'\
    > "$HOME/.journalscript/hooks/open"

    run journal.sh life
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "$todays_entry"
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "default open hook"
}

# 2.3.3 Test open hook has access to all of JOURNALSCRIPT vars
_2_3_3=\
"2.3.3 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And a the default open hook exists. "\
"When the command 'write' is invoked. "\
"Then journalscrip runs fallback 'hook'."
@test "${_2_3_3}" {
    local journal_dir="$HOME/Documents/journals/life"
    mkdir -p "$journal_dir"
    local todays_date=$(date +%Y-%m-%d)
    local file_name="$todays_date.txt"
    local todays_entry="$journal_dir/$todays_date.txt"
    # A little hack to test whether fallback happens:
    # I cant set the EDITOR to a real editor because they are interactive
    # thus the test will hang
    # Instead I print to stdout. The 1st argument is the jounal entry file name
    # So by testing it is in the output, I ensure JOURNALSCRIPT_EDITOR was
    # invoked
    export JOURNALSCRIPT_EDITOR="eval echo \""\
"JOURNALSCRIPT_JOURNAL_NAME=\$JOURNALSCRIPT_JOURNAL_NAME,"\
"JOURNALSCRIPT_JOURNAL_DIRECTORY=\$JOURNALSCRIPT_JOURNAL_DIRECTORY,"\
"JOURNALSCRIPT_JOURNAL_ENTRY=\$JOURNALSCRIPT_JOURNAL_ENTRY,"\
"JOURNALSCRIPT_IS_NEW_JOURNAL_ENTRY=\$JOURNALSCRIPT_IS_NEW_JOURNAL_ENTRY,"\
"JOURNALSCRIPT_JOURNAL_ENTRY_FILE_NAME=\$JOURNALSCRIPT_JOURNAL_ENTRY_FILE_NAME\""

    run journal.sh life
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "JOURNALSCRIPT_JOURNAL_NAME=life"
    assert_output --partial "JOURNALSCRIPT_JOURNAL_DIRECTORY=$journal_dir"
    assert_output --partial "JOURNALSCRIPT_JOURNAL_ENTRY=$todays_entry"
    assert_output --partial "JOURNALSCRIPT_JOURNAL_ENTRY_FILE_NAME=$file_name"
    assert_output --partial "JOURNALSCRIPT_IS_NEW_JOURNAL_ENTRY=1"
    # assert generated journal entry 
    assert_file_exists "$todays_entry"
}

# 2.3.4 Test editor specific hook
_2_3_4=\
"2.3.4 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And the default open hooks exists. "\
"And an editor specific open hook exists which matches the editor. "\
"When the command 'write' is invoked. "\
"Then journalscrip runs the default 'hook'."
@test "${_2_3_4}" {
    mkdir -p "$HOME/Documents/journals/life"
    mkdir -p "$HOME/.journalscript/hooks"
    mkdir -p "$HOME/.journalscript/hooks/open.d"
    local todays_date=$(date +%Y-%m-%d)
    local journal_entry="$HOME/Documents/journals/life/$todays_date.txt"
    printf 'echo "default open hook" > $JOURNALSCRIPT_JOURNAL_ENTRY'\
    > "$HOME/.journalscript/hooks/open"
    printf 'echo "specific hook" > $JOURNALSCRIPT_JOURNAL_ENTRY'\
    > "$HOME/.journalscript/hooks/open.d/specific"
    export JOURNALSCRIPT_EDITOR="specific"

    run journal.sh life
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "$todays_entry"
    # assert generated journal entry 
    assert_file_exists "$journal_entry"
    assert_file_contains "$journal_entry" "specific hook"
}

# 2.3.5 Test backup hook is executed if it exists
_2_3_5=\
"2.3.5 Given no config file. "\
"And no env overrides. "\
"And existing journal. "\
"And no open hooks. "\
"And default backup hooks. "\
"When the command 'write' is invoked. "\
"Then journalscrip runs fallback 'hook'."
@test "${_2_3_5}" {
    mkdir -p "$HOME/Documents/journals/life"
    mkdir -p "$HOME/.journalscript/hooks"
    local todays_date=$(date +%Y-%m-%d)
    local todays_entry="$HOME/Documents/journals/life/$todays_date.txt"
    printf 'echo "default backup hook"' > "$HOME/.journalscript/hooks/backup"
    # A little hack to test whether fallback happens:
    # I cant set the EDITOR to a real editor because they are interactive
    # thus the test will hang
    # Instead I print to stdout. The 1st argument is the jounal entry file name
    # So by testing it is in the output, I ensure JOURNALSCRIPT_EDITOR was
    # invoked
    export JOURNALSCRIPT_EDITOR="echo"

    run journal.sh life
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "$todays_entry"
    assert_output --partial "default backup hook"
    # assert generated journal entry 
    assert_file_exists "$todays_entry"
}

# TODO: do so when errors are emmited properly
# 2.3.6 Test backup hook is not executed when open hook fails

teardown() {
    unset JOURNALSCRIPT_EDITOR
}


























