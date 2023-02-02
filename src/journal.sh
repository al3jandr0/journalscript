#!/usr/bin/env bash
# Dependencies
# - bash
# - git
# - date
#
# Descision:
# 0. journalscript is desined to work out of the box withouth any configuration
# 1. If no journal exists, create new journal directory
#    And promp user for confirmation
# 2. Each journal entry goes into its own file, and the file name is the date
# 3. Journal enties are stored under a directory named after the journal
# 4. The journal directory location is controlled by JOURNALSCRIPT_DATA_DIR,
#    and it defaults to $HOME/Documents/journals
# TODO: throw errors properly
# TODO: prune directories ending '/'
#
################################################################################
# Globals                                                                      #
################################################################################
_ME="journalscript"
_VERSION="0.0.1"
_COMMADN_LS="_ls"
_COMMAND_WRITE="_write"
_COMMAND_CONFIGURE="_configure"
_DEFAULT_COMMAND="$_COMMAND_WRITE"

################################################################################
# Parse Arguments                                                              #
################################################################################
_PRINT_HELP=0
_COMMAND=""
_COMMAND_ARGUMENTS=()
for __opt in "$@"; do
    case "${__opt}" in
        -h|--help)
            _PRINT_HELP=1
            ;;
        ls)
            _COMMAND="$_COMMAND_LS"
            ;;
        configure)
            _COMMAND="$_COMMAND_CONFIGURE"
            ;;
        write)
            _COMMAND="$_COMMAND_WRITE"
            ;;
        *)
            # All unrecognized options are treated as arguments to the default
            # command
            _COMMAND_ARGUMENTS+=("${__opt}")
            ;;
    esac
    shift
done

################################################################################
# Env                                                                          #
################################################################################
# System default env
# Error out if $HOME is not defined
HOME=${HOME:?"\$HOME is not defined"}
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
EDITOR="${EDITOR:-vi}"

# Journalsscript env

# Look for configuration in the following locations in order
# 1. $XDG_CONFIG_HOME/journalscript/journalscript.env
# 2. $HOME/.config/journalscript/journalscript.env
# 3. $HOME/.journalscript/journalscript.env
_JOURNALSCRIPT_CONF_DIR="$HOME/.journalscript"
if test -d "$XDG_CONFIG_HOME/journalscript"; then
    _JOURNALSCRIPT_CONF_DIR="$XDG_CONFIG_HOME/journalscript"
fi

# Configuration env vars are used in the following order of priority
# 1. ENV
# 2. Configuration file
# 3. Defaults

# 1 & 2. Source configuration file, if it exists
if test -f "$_JOURNALSCRIPT_CONF_DIR/journalscript.env"; then
    # for each line in the configuration file
    while read line; do
        # ignore comments
        [[ "$line" =~ ^#.*$ ]] && continue
        # split each line into name and value. name=var[0], value=var[1]
        # each line follows the format: <name>=<value>
        readarray -t -d '=' var < <(printf '%s' "$line")
        # expand values since they may invlude env vars
        _expanded_value=$(eval printf '%s' "${var[1]}")
        # set configuration file variable only if it is not already set in env
        declare "${var[0]}"="${!var[0]:-$_expanded_value}"
    done < "$_JOURNALSCRIPT_CONF_DIR/journalscript.env"
fi

# 3. Set default values if env var has no value 
JOURNALSCRIPT_DEFAULT_JOURNAL=${JOURNALSCRIPT_DEFAULT_JOURNAL:-"life"}
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-"txt"}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-"$EDITOR"}
# TODO: rename DATA DIR to journals dir
JOURNALSCRIPT_DATA_DIR=${JOURNALSCRIPT_DATA_DIR:-"$XDG_DOCUMENTS_DIR/journals"}

# Template directory default is set to whichever exists in this order
# 1. JOURNALSCRIPT_DATA_DIR/.journalscript/templates
# 2. _JOURNALSCRIPT_CONF_DIR/.journalscript/templates
# 3. Empty value
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-""}
if [[ -z "$JOURNALSCRIPT_TEMPLATE_DIR" ]] ; then
    JOURNALSCRIPT_TEMPLATE_DIR="$JOURNALSCRIPT_DATA_DIR/.journalscript/templates"
    if ! test -d "$JOURNALSCRIPT_TEMPLATE_DIR"; then
        JOURNALSCRIPT_TEMPLATE_DIR="$_JOURNALSCRIPT_CONF_DIR/templates"
    fi
    if ! test -d "$JOURNALSCRIPT_TEMPLATE_DIR"; then
        # set no directory
        JOURNALSCRIPT_TEMPLATE_DIR=""
    fi
fi
_JOURNALSCRIPT_HOOKS_DIR="$_JOURNALSCRIPT_CONF_DIR/hooks"

################################################################################
# Functions                                                                    #
################################################################################

# Writes a template into a new journal entry
#
# Templates' parent directory is specified with JOURNALSCRIPT_TEMPLATE_DIR.
# Whithin that directory this function searches first for a journal-specific
# template which determined by a template file stored under /template.d that
# matching the name of the journal and if such file is not found, then the
# function uses the fallback template /template.  In case there is no fallback
# template, then today's date is written on teh first list of the journal entry
# as a default behavior
#
# TODO: Implement bash (dyamic templates)
_write_template() {
    local journal_name="$1"   # Name of the journal
    local journal_entry="$2"  # Full path to journal entry (file)
    local timestamp=$(date +'%a %b %d %I:%M %p %Z %Y')

    # if no directory, then writes today's date as a fallback template
    if [[ -z "$JOURNALSCRIPT_TEMPLATE_DIR" ]]; then
        printf "%s\n" "$timestamp" > "$journal_entry"

    # Templates are searched in these locations in this order
    # 1. JOURNALSCRIPT_TEMPLATE_DIR/template.d/<journal_name>
    # 2. JOURNALSCRIPT_TEMPLATE_DIR/template 
    elif test -f "$JOURNALSCRIPT_TEMPLATE_DIR/template.d/$journal_name"; then
        cp "$JOURNALSCRIPT_TEMPLATE_DIR/template.d/$journal_name" $journal_entry
    elif test -f "$JOURNALSCRIPT_TEMPLATE_DIR/template"; then
        cp "$JOURNALSCRIPT_TEMPLATE_DIR/template" $journal_entry
    # Lastly, if template directory is specified but it has no contents
    # fallback to writing date 
    else
        printf "%s\n" "$timestamp" > "$journal_entry"
    fi
}

# 1. findis open or backup hook
# Hooks are located under the parent directory JOURNALSCRIPT_CONF_DIR/hooks
# each hook type is searchd following the same pattern. 
# journalscript searches for a hook specific for an editor (or backup-tool) 
# under /hooks/open.d/ (or /hooks/backup.d/). Hooks must match the name of the 
# editor (or backup-tool). i.e. /open.d/vim, open.d/git, etc.
# There is a fallback hook for each type:
# /hooks/open for open hook, and /hooks/backup for backup hook
# The fallbacks are used if no specific hook is found
_find_hook() {
    local action="$1"  # open or backup
    local tool="$2"    # Editor or backup tool

    if test -f "$_JOURANLSCRIPT_HOOKS_DIR/$action.d/$tool"; then
        echo "$_JOURANLSCRIPT_HOOKS_DIR/$action.d/$tool"
    elif test -f "$hooks_dir/$action"; then
        echo "$hooks_dir/$action"
    else
        echo ""
    fi
}

# Opens a journal entry
#
# It attempts to run an user defined hook to open the journal entry
# If no hook is found, then it fallbacks to invokign the configured editor
#
# TODO: set ENV for hook
_open_journal_entry() {
    local journal_entry="$1"
    local open_hook=$( _find_hook "open" "$JOURNALSCRIPT_EDITOR" )

    # invoke configured editor directly and run backup hook
    if [[ -n "$open_hook" ]]; then
        . "$open_hook"
    else
    # If there is no open hook, default to invokig the configured editor
        $JOURNALSCRIPT_EDITOR "$journal_entry"
    fi
}

# Opens backup hook
#
# It attempts to run a user defined hook, if none is found then it does nothign
_backup_journal_entry() {
    local journal_entry="$1"
    local backup_hook=$( _find_hook "backup" "git" )

    # if there is no backup hook, do nothing
    if [[ -n "$backup_hook" ]]; then
        . "$backup_hook" 
    fi
}

###########################################################################  Old

write_template() {
    local journalName="$1"
    local journalEntryFile="$2"
    local template="$JS_CONF_TEMPLATE_DIR/$journalName"

    if test -f "$template"; then
        while read line; do
            echo "echo \"$line\"" | bash >> "$journalEntryFile"
        done < "$template"
    else
        # default template is a date stamp
        echo "$(date)" > "$journalEntryFile"
    fi
}

# TODO: Think about what ENV_VARS or params to expose to a backup function hook 
backup_file() {
    local commit_msg=""
    if [ "$2" -eq 1 ]; then
        commit_msg="Adds entry"
    else
        commit_msg="Edits entry"
    fi
    git -C "$JS_CONF_DATA_DIR" add "$1" && git -C "$JS_CONF_DATA_DIR" commit -m "$commit_msg" && git -C "$JS_CONF_DATA_DIR" push
}

# TODO: Fix files to remove the directory in position 0
open_files() {
    # TODO: do this with arguments when refactoring?
    local files=("$@")
    if [[ "$JS_CONF_EDITOR" == *"vim" ]]; then
        $JS_CONF_EDITOR -o "${files[@]}"
    else
        $JS_CONF_EDITOR "${files[0]}"
    fi
}

today=$(date +%Y-%m-%d)
filename="$JS_CONF_DATA_DIR/$JOURNAL/$today.$JS_CONF_FILE_TYPE"
case $COMMAND in
    ls)
        # Validate
        # Execute
        # TODO: filter ignored files
        ls "$JS_CONF_DATA_DIR"
        exit 0
        ;;
    write)
        # Validate
        if ! test -d "$JS_CONF_DATA_DIR"; then
            echo "WANR: Looks like you dont have a designated directory to store your journals."
            echo "WANR: The location $JS_CONF_DATA_DIR does not exist in your system"
            echo "WARN: Run 'journalscript configure' to setup a directory to store your journals"
            exit 1
        elif ! test -d "$JS_CONF_DATA_DIR/$JOURNAL"; then
            echo "WARN: No journal found with name $JOURNAL"
            read -p "Would you like to create a new jurnal named $JOURNAL? (y/n):" yes_no
            if yes_no; then
                mkdir "$JS_CONF_DATA_DIR/$JOURNAL"
            else
                exit 0
            fi
        fi
        # Execute
        SUB_COMMAND="$SUB_COMMAND_EDIT"
        if ! test -f $filename; then
            SUB_COMMAND="$SUB_COMMAND_CREATE"
            write_template "$JOURNAL" "$filename"
        fi
        readarray -t filesToOpen < <(ls -tA $JS_CONF_DATA_DIR/$JOURNAL/* | head -n2) # 2 most recent files
        # Enable a backup hook
        open_files "${filesToOpen[@]}" && backup_file "$filename" "$SUB_COMMAND"
        exit 0
        ;;
esac

################################################################################
# Commands                                                                     #
################################################################################

# TODO: print hooks
# Accepts up to one argument -the subcommand (init, or show)-, or no arguments
# In case of no arguments, defaults to 'show' subcommand
_configure() {
    # default command
    local sub_command="show"
    # Accept only up to 1 argument. Error if more than 1 argument
    if [[ "${#@}" -eq 1 ]]; then
        sub_command="$1"
    elif [[ "${#@}" -gt 1 ]]; then
        echo "ERROR. configuration command supports up to 1 argument"
        exit 1
    fi
    # if no arguments, then default to show sub_command 

    # Run sub commands:
    if [[ "$sub_command" == "show" ]]; then
		cat <<-EOF
		_JOURNALSCRIPT_CONF_DIR="${_JOURNALSCRIPT_CONF_DIR}"
		JOURNALSCRIPT_FILE_TYPE="${JOURNALSCRIPT_FILE_TYPE}"
		JOURNALSCRIPT_EDITOR="${JOURNALSCRIPT_EDITOR}"
		JOURNALSCRIPT_DATA_DIR="${JOURNALSCRIPT_DATA_DIR}"
		JOURNALSCRIPT_TEMPLATE_DIR="${JOURNALSCRIPT_TEMPLATE_DIR}"
		JOURNALSCRIPT_DEFAULT_JOURNAL="${JOURNALSCRIPT_DEFAULT_JOURNAL}"
		EOF
    elif [[ "$sub_command" == "init" ]]; then
        . init_configuration.sh
    # unknown command.
    else
        echo "ERROR. Unsupported argument '${args[0]}' of 'configure'."
        echo "See journalscript configure --help for supported options"
        exit 1
    fi
}

# Writes journal entries.
#
# In case of new entires cretes the a new journal entry. And in case of
# existing entres it opens the existng entry.
# It populates new etries with templates and it invokes open and backup hooks
# for editing and saving journal entries.
# _write accepts up to one argument which is the journal name 
# Or no arguments, in such case the journal name become _DEFAILT_JOURNAL_NAME
_write() {
    # The command deosnt accept more than 1 argumetn. Error out in such case
    if [[ ${#@} -gt 1 ]]; then
        echo "ERROR. jounal command supports up to 1 argument"
        exit 1
    fi
    # fail if JOURNALSCRIPT_DATA_DIR does not exist
    if [[ -z "$JOURNALSCRIPT_DATA_DIR" ]]; then
        echo "fail if JOURNALSCRIPT_DATA_DIR does not exist"
        exit 1
    fi
    # if no argument (journal name), then default to the default journal 
    local journal_name="${1:-$JOURNALSCRIPT_DEFAULT_JOURNAL}"
    echo "$journal_name"
    # directory that hosts all the entries of the journal
    local journal_dir="$JOURNALSCRIPT_DATA_DIR/$journal_name"
    # full path the journal entry file to crete/edit
    local todays_date=$(date +%Y-%m-%d)  # date format: YYY-mm-dd
    local todays_entry="$journal_dir/$todays_date.$JOURNALSCRIPT_FILE_TYPE"
    echo "$todays_entry"
    # if the journal directory doesnt not exist, notify user and create it if
    # the user agrees
    if ! test -d "$journal_dir"; then
        read -p "The journal directory '$journal_dir' doesn't exist. Do you wish to create it (y/n):" confirm
        [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0
        mkdir -p "$journal_dir"
    fi

    # Write template into new entries
    local is_new_file=0
    if ! test -f "$todays_entry";then
        is_new_file=1
        _write_template "$journal_name" "$todays_entry"
    fi
   
    # TODO: set env vars for hooks
    # runs open and backup hook (upon success)
    _open_journal_entry "$todays_entry" && _backup_journal_entry
}

_main() {
    if [[ ${_PRINT_HELP} -eq 1 ]]; then
        _help "$_COMMAND"
        exit 0
    fi
    # If $_COMMAND is not provided, then set to 'write' (default command)
    if [[ -z "$_COMMAND" ]]; then
        _COMMAND=$_COMMAND_WRITE
    fi
    echo "$_COMMAND ${_COMMAND_ARGUMENTS[@]}"
    $_COMMAND "${_COMMAND_ARGUMENTS[@]}"
}

################################################################################
# Run Program                                                                  #
################################################################################
# Call the `_main` function after everything has been defined.
_main
