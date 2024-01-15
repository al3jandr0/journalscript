################################################################################
# Test set for command: configure                                              # 
################################################################################

# timeout from any test after 2 seconds
BATS_TEST_TIMEOUT=2

setup() {
    load 'test_helper/common-setup'
    _common_setup
    export JOURNALSCRIPT_EDITOR=":" # no-op editor
}

###############################################################################
# Command: configure                                                          #
###############################################################################
# bats file_tags=write
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

# 2.1.1 Test command creates default journal if journal doesn't exist
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

# 2.1.2 Test command creates provided journal if journal doesn't exist
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

# 2.1.3 Test command creates a journal entry in the journal directory
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
    assert_file_exists "$HOME/Documents/journals/life/$todays_date.md"
}

# 2.1.4 Test command doesn't create a new file if target file exits 
_2_1_4=\
"2.1.4 Given no config file. "\
"And no env overrides. "\
"And a existing journal with an exiting entry for today. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_1_4}" {
    mkdir -p "$HOME/Documents/journals/life"
    local todays_date=$(date +%Y-%m-%d)
    local file="$HOME/Documents/journals/life/$todays_date.md"
    printf "Existing entry" > "$file"

    run journal.sh 
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$file"
    cat "$file"
    assert_file_contains "$file" "^Existing entry$"
}

_2_1_5=\
"2.1.5 Given no config file. "\
"And no env overrides. "\
"And a existing journal with an existing entry for yesterday. "\
"When the command 'write' is invoked. "\
"A new entry is created in the journal directory with today's date."
@test "${_2_1_5}" {
    mkdir -p "$HOME/Documents/journals/life"
    local today_date=$(date +%Y-%m-%d)
    local yday_date=$(date -d "1 day ago" +"%Y-%m-%d")
    local today_file="$HOME/Documents/journals/life/$today_date.md"
    local yday_file="$HOME/Documents/journals/life/$yday_date.md"
    printf "Existing entry" > "$yday_file"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$yday_file"
    assert_file_exists "$today_file"
}

_2_1_6=\
"2.1.6 Given no config file. "\
"And monthly group by override. "\
"When the command 'write' is invoked. "\
"Then a new entry is created in the journal directory with the current's month date."
@test "${_2_1_6}" {
    export JOURNALSCRIPT_GROUP_BY="MONTH"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y-%m)
    local file="$HOME/Documents/journals/life/$current_month.md"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$file"
}

_2_1_7=\
"2.1.7 Given no config file. "\
"And monthly group by override. "\
"And a existing journal with an exiting entry for the current month. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_1_7}" {
    export JOURNALSCRIPT_GROUP_BY="MONTH"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y-%m)
    local file="$HOME/Documents/journals/life/$current_month.md"
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

#########################################################################
#
# TODO: repeat with YEAR group by
#
#########################################################################

_2_1_8=\
"2.1.8 Given no config file. "\
"And yearly group by override. "\
"When the command 'write' is invoked. "\
"Then a new entry is created in the journal directory with the current's year date."
@test "${_2_1_8}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_year=$(date +%Y)
    local file="$HOME/Documents/journals/life/$current_year.md"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert generated journal entry 
    assert_file_exists "$file"
}

_2_1_9=\
"2.1.9 Given no config file. "\
"And monthly group by override. "\
"And a existing journal with an exiting entry for the current year. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_1_9}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y)
    local file="$HOME/Documents/journals/life/$current_year.md"
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
# Command: write (with hooks)                                                 #
###############################################################################

# 2.3.1 Test fallback open hook behavior
# bats test_tags=write:hook
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
    local todays_entry="$HOME/Documents/journals/life/$todays_date.md"
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
# bats test_tags=write:hook
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
    local journal_entry="$HOME/Documents/journals/life/$todays_date.md"
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
# bats test_tags=write:hook
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
    local file_name="$todays_date.md"
    local todays_entry="$journal_dir/$todays_date.md"
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
# bats test_tags=write:hook
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
    local journal_entry="$HOME/Documents/journals/life/$todays_date.md"
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
# bats test_tags=write:hook
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
    local todays_entry="$HOME/Documents/journals/life/$todays_date.md"
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


























