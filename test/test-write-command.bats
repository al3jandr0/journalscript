################################################################################
# Test set for command: configure                                              # 
################################################################################

# timeout from any test after 2 seconds
BATS_TEST_TIMEOUT=2

setup() {
    load 'test_helper/common-setup'
    _common_setup
    export JOURNALSCRIPT_EDITOR=":" # no-op editor
    export JOURNALSCRIPT_GROUP_BY="DAY" # no-op editor
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
"And group by day env override. "\
"And no existing journal. "\
"When the command 'write' is invoked. "\
"Then journalscript should prompt the user to create a new journal dir with "\
"named 'myjournal' at the default journal directory. "\
"And a new entry is created in the journal directory with with the expected "\
" name format."
@test "${_2_1_3}" {
    export JOURNALSCRIPT_GROUP_BY="DAY" # no-op editor
    run journal.sh < <(printf "y\n")
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "Created new file"
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
    local today_header=$(date +'%a %b %d %Y')
    printf "%s\nExisting entry" "$today_header" > "$file"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output ""
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "^Existing entry$"
}

# 2.1.5 Test command doesn't create a new file if target file exits
# And that exiting file wasnt overrwrite, and that appropiate message
# is displayed when the file is edited
_2_1_5=\
"2.1.5 Given no config file. "\
"And no env overrides. "\
"And a existing journal with an exiting entry for today. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_1_5}" {
    mkdir -p "$HOME/Documents/journals/life"
    local todays_date=$(date +%Y-%m-%d)
    local file="$HOME/Documents/journals/life/$todays_date.md"
    printf "Existing entry" > "$file"
    export JOURNALSCRIPT_EDITOR="printf '\nedit\n' >> $file" # no-op editor

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    assert_output --partial "Edited entry"
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "^Existing entry$"
    assert_file_contains "$file" "edit"
}

# 2.1.6 Test command creates a journal entry in the journal directory
#       When outdated file exists with DAY group by
_2_1_6=\
"2.1.6 Given no config file. "\
"And no env overrides. "\
"And a existing journal with an existing entry for yesterday. "\
"When the command 'write' is invoked. "\
"A new entry is created in the journal directory with today's date."
@test "${_2_1_6}" {
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

#########################################################################
# Month group by
#########################################################################

# 2.2.1 Test command creates a journal entry in the journal directory
#       When outdated file exists with MONTH group by
_2_2_1=\
"2.2.1 Given no config file. "\
"And monthly group by override. "\
"When the command 'write' is invoked. "\
"Then a new entry is created in the journal directory with the current's month date."
@test "${_2_2_1}" {
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

# 2.2.2 Test command does not creates a journal entry in the journal directory
#       When current file exists with MONTH group by
_2_2_2=\
"2.2.2 Given no config file. "\
"And monthly group by override. "\
"And a existing journal with an exiting entry for the current month. "\
"When the command 'write' is invoked. "\
"Then No new entry is created in the journal directory."
@test "${_2_2_2}" {
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
# YEAR group by
#########################################################################

# new file, new entry
_2_3_1=\
"2.3.1 Given no config file. "\
"And yearly group by override. "\
"When the command 'write' is invoked. "\
"Then a new file with a new entry is created in the journal directory with the current's year date."
@test "${_2_3_1}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_year=$(date +%Y)
    local file="$HOME/Documents/journals/life/$current_year.md"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert info message
    assert_output --partial "Created new file"
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "^Existing entry$"
    # assert new header (new netry) is inserted
    local today_header=$(date +'%a %b %d %Y')
    assert_file_contains "$file" "$today_header"
}

# existing file, new entry
_2_3_2=\
"2.3.2 Given no config file. "\
"And monthly group by override. "\
"And a existing journal with an exiting entry for yesterday. "\
"When the command 'write' is invoked. "\
"Then no new file is created, and a new entry is created for the existing file in the journal directory."
@test "${_2_3_2}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y)
    local yday_header=$(date -d "1 day ago" +'%a %b %d %Y')
    local file="$HOME/Documents/journals/life/$current_year.md"
    printf "%s\nExisting entry" "$yday_header" > "$file"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert info message
    assert_output --partial "Created new entry"
    # assert generated journal entry 
    assert_file_exists "$file"
    # assert new header (new netry) is inserted
    local today_header=$(date +'%a %b %d %Y')
    assert_file_contains "$file" "$today_header"
}

# existing file, current entry edited 
_2_3_3=\
"2.3.3 Given no config file. "\
"And yearly group by override. "\
"And a existing journal with an exiting entry for the current date. "\
"When the command 'write' is invoked. "\
"And the user makes an edit. "\
"Then no new file is created, and journalscript informs the user that the file was edited."
@test "${_2_3_3}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y)
    local today_header=$(date +'%a %b %d %Y')
    local file="$HOME/Documents/journals/life/$current_year.md"
    printf "%s\nExisting entry" "$today_header" > "$file"
    export JOURNALSCRIPT_EDITOR="printf '\nedit\n' >> $file" # no-op editor

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert info message
    assert_output --partial "Edited entry"
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "edit$"
}

# existing file, current entry, nothign is done
_2_3_4=\
"2.3.4 Given no config file. "\
"And monthly group by override. "\
"And a existing journal with an exiting entry for the current date. "\
"When the command 'write' is invoked. "\
"Ands the user performs no edits. "\
"Then no new file is created, and a no new entry is created, and journalscript outputs nothing."
@test "${_2_3_4}" {
    export JOURNALSCRIPT_GROUP_BY="YEAR"
    mkdir -p "$HOME/Documents/journals/life"
    local current_month=$(date +%Y)
    local today_header=$(date +'%a %b %d %Y')
    local file="$HOME/Documents/journals/life/$current_year.md"
    printf "%s\nExisting entry" "$today_header" > "$file"

    run journal.sh
    # assert command finishes sucessfully
    assert_success
    # assert nothing is written to stderr
    assert_equal "$stderr" ""
    # assert info message
    assert_output ""
    # assert generated journal entry 
    assert_file_exists "$file"
    assert_file_contains "$file" "Existing entry$"
}

teardown() {
    unset JOURNALSCRIPT_EDITOR
}


























