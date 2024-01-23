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
# 4. The journal directory location is controlled by JOURNALSCRIPT_JOURNAL_DIR,
#    and it defaults to $HOME/Documents/journals

################################################################################
# Globals                                                                      #
################################################################################
set -e
set -o nounset
set -o pipefail
_ME="journalscript"
_VERSION="0.5.3"
_COMMAND_LS="_ls"
_COMMAND_WRITE="_write"
_COMMAND_CONFIGURE="_configure"

################################################################################
# Parse Arguments                                                              #
################################################################################
_PRINT_HELP=0
_PRINT_VERSION=0
_COMMAND=""
_COMMAND_ARGUMENTS=()
for __opt in "$@"; do
    case "${__opt}" in
    -h | --help)
        _PRINT_HELP=1
        ;;
    -v | --version)
        _PRINT_VERSION=1
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
EDITOR="${EDITOR:-vim}"

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
    while read line || [ -n "$line" ]; do
        # ignore comments
        [[ "$line" =~ ^#.*$ ]] && continue
        # split each line into name and value. name=var[0], value=var[1]
        # each line follows the format: <name>=<value>
        readarray -t -d '=' var < <(printf '%s' "$line")
        # expand values since they may invlude env vars
        _expanded_value=$(eval printf '%s' "${var[1]}")
        # set configuration file variable only if it is not already set in env
        declare "${var[0]}"="${!var[0]:-$_expanded_value}"
    done <"$_JOURNALSCRIPT_CONF_DIR/journalscript.env"
fi

# 3. Set default values only if var has no value
JOURNALSCRIPT_DEFAULT_JOURNAL=${JOURNALSCRIPT_DEFAULT_JOURNAL:-"life"}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-"$EDITOR"}
JOURNALSCRIPT_GROUP_BY=${JOURNALSCRIPT_GROUP_BY:-"YEAR"}
JOURNALSCRIPT_JOURNAL_DIR=${JOURNALSCRIPT_JOURNAL_DIR:-"$XDG_DOCUMENTS_DIR/journals"}
JOURNALSCRIPT_SYNC_BACKUP=${JOURNALSCRIPT_SYNC_BACKUP:-}
_JOURNALSCRIPT_HOOKS_DIR="$_JOURNALSCRIPT_CONF_DIR/hooks"
# Expand ~
JOURNALSCRIPT_EDITOR="${JOURNALSCRIPT_EDITOR/\~/$HOME}"
JOURNALSCRIPT_JOURNAL_DIR="${JOURNALSCRIPT_JOURNAL_DIR/#\~/$HOME}"
_JOURNALSCRIPT_HOOKS_DIR="${_JOURNALSCRIPT_HOOKS_DIR/#\~/$HOME}"

################################################################################
# Functions                                                                    #
################################################################################

# Prints to stdr with some formating, and exits with code 1
_fail() {
    {
        printf "%s " "$(tput setaf 1)ERROR$(tput sgr0)"
        printf "%s\n" "${@}"
    } 1>&2
    exit 1
}

_help() {
    if [[ -z "${@}" ]]; then
        cat >&1 <<-EOF

			Journalscript, version $_VERSION

			Usage: journal [options]
			       journal COMMAND [options] [ARG...]

			Options:
			  --help        Prints this message and quits
			  -v, --version Prints version information and quits

			Commands:
			  write         Writes a new journal entry. Default command, it executes in
			                the absence of COMMAND.
			  configure     Assits configuring journalscript

			Run journal COMMAND --help for more information on a command.
		EOF
    elif [[ "$1" =~ write|configure ]]; then
        _help$1
    fi
}

# 1. finds hooks
# Hooks are located under the parent directory JOURNALSCRIPT_CONF_DIR/hooks
# each hook type is searchd following the same pattern.
# journalscript searches for a hook specific for an editor (or backup-tool)
# under /hooks/sync.d/ (or /hooks/backup.d/). Hooks must match the name of the
# editor (or backup-tool). i.e. /backup.d/git, etc.
# There is a fallback hook for each type:
# For example: /hooks/backup for backup hook
# The fallbacks are used if no specific hook is found
_find_hook() {
    local action="$1" # sync, backup
    local tool="${2:-}"

    if test -f "$_JOURNALSCRIPT_HOOKS_DIR/$action.d/$tool"; then
        echo "$_JOURNALSCRIPT_HOOKS_DIR/$action.d/$tool"
    elif test -f "$_JOURNALSCRIPT_HOOKS_DIR/$action"; then
        echo "$_JOURNALSCRIPT_HOOKS_DIR/$action"
    else
        echo ""
    fi
}

is_git_repo() {
    git -C "$1" rev-parse >/dev/null 2>&1
}

quiet_git() {
    git "$@"
    #git "$@" >/dev/null 2>&1
}

# Runs backup hook (backup journal)
#
# It attempts to run a user defined hook, if none is found then it does nothign
_backup_journal() {
    local backup_hook=$(_find_hook "backup" "$JOURNALSCRIPT_SYNC_BACKUP")

    # if there is no backup hook, do nothing
    if [[ -n "$backup_hook" ]]; then
        printf "==> Backing up with hook %s\n" "${backup_hook##*/}"
        . "$backup_hook"
    fi
}

_sync_journal() {
    local sync_hook=$(_find_hook "sync" "$JOURNALSCRIPT_SYNC_BACKUP")

    # if there is no backup hook, do nothing
    if [[ -n "$sync_hook" ]]; then
        printf "==> Synching with hook %s\n" "${sync_hook##*/}"
        . "$sync_hook"
    fi
}

_check_md5sum() {
    local md5sum_hash=$1
    md5sum --check --status < <(echo "$md5sum_hash") >/dev/null 2>&1
}

################################################################################
# Commands                                                                     #
################################################################################

_help_configure() {
    cat >&1 <<-EOF

		Usage: journal configure [options] [show|init] 

		Configure command assists users customizing journalscript.  It supports
		two sub-commands: show, init.  When no sub-command is provided, configure
		    defaults to 'show'.

		show:
		  Displays the values of journalscript's configuration.

		init:
		  Launches an interactive wizzard that helps users to create a configuration.

		Options:
		  --help        Prints this message and quits

		Examples:
		    journal configure           Runs configure show
		    journal configure show      Displays the configuration
		    journal configure init      Launches wizard to create a configuration
	EOF
}

# Accepts up to one argument -the subcommand (init, or show)-, or no arguments
# In case of no arguments, defaults to 'show' subcommand
_configure() {
    # default command
    local sub_command=${1:-"show"}
    # Accept only up to 2 arguments. Error if more than 2 arguments
    if [[ "${#@}" -gt 2 ]]; then
        _fail "'configure' command supports up to 2 argument only."
    fi
    # if no arguments, then default to show sub_command

    # run sub commands:
    if [[ "$sub_command" == "show" ]]; then
        local conf_file_msg="No configuration file found."
        if test -f "$_JOURNALSCRIPT_CONF_DIR/journalscript.env"; then
            conf_file_msg="Configuration found at: $_JOURNALSCRIPT_CONF_DIR/journalscript.env"
        fi
        cat <<-EOF
			${conf_file_msg}
			Resolved configuration:
			JOURNALSCRIPT_SYNC_BACKUP="${JOURNALSCRIPT_SYNC_BACKUP}"
			JOURNALSCRIPT_EDITOR="${JOURNALSCRIPT_EDITOR}"
			JOURNALSCRIPT_JOURNAL_DIR="${JOURNALSCRIPT_JOURNAL_DIR}"
			JOURNALSCRIPT_GROUP_BY="${JOURNALSCRIPT_GROUP_BY}"
			JOURNALSCRIPT_DEFAULT_JOURNAL="${JOURNALSCRIPT_DEFAULT_JOURNAL}"
		EOF
    # if verbose, Then
    # display whether a configuration file was found and Where
    # Also display journalscript configuration directory
    elif [[ "$sub_command" == "init" ]]; then
        local option=${2:-""}
        if [[ -n "$option" ]] && [[ "$option" != "--print" ]]; then
            _fail "Unsupported option '$2' for command 'configure init'."
        fi
        _configure_init "$option"
    else
        # unknown command.
        _fail "Unsupported argument '$sub_command' of command 'configure'."
    fi
}

###############################################################################
# Interative script / wizard to asssit on the creation of new configuration   #
# file for journalscript                                                      #
###############################################################################
_configure_init() {
    # Read (prompt) configuration preferences from user
    #printf "Type your selections. press enter / leave black to choose the default value. Default values are in parthensiss '()'.\n"
    # TODO: how to make local
    read -p "Editor ($JOURNALSCRIPT_EDITOR):" prompt_editor
    # Language improvement. Where do you want to save your journals
    read -p "Where do you wish to save your journals [path/to/directory] ? ($JOURNALSCRIPT_JOURNAL_DIR):" prompt_journal_dir
    journal_dir=${prompt_journal_dir:-$JOURNALSCRIPT_JOURNAL_DIR}
    read -p "Where do you wish to store the configuration [path/to/directory] ? ($_JOURNALSCRIPT_CONF_DIR):" prompt_conf_dir
    read -p "Would you like to group entires by DAY, MONTH, or YEAR. That is to create a journal file per DAY, MONTH, or YEAR [DAY|MONTH|YEAR] ? ($JOURNALSCRIPT_GROUP_BY):" prompt_group_by
    # When invoking 'journal' this would be the journal that gets openned
    read -p "Would you like to set a default journal [optional] ($JOURNALSCRIPT_DEFAULT_JOURNAL):" prompt_default_journal

    # Default values if no user input
    local editor=${prompt_editor:-$JOURNALSCRIPT_EDITOR}
    local default_journal=${prompt_default_journal:-$JOURNALSCRIPT_DEFAULT_JOURNAL}
    local conf_dir=${prompt_conf_dir:-$_JOURNALSCRIPT_CONF_DIR}
    local group_by=${prompt_group_by:-$JOURNALSCRIPT_GROUP_BY}
    local conf_file="${conf_dir}/journalscript.env"
    # expand ~
    journal_dir="${journal_dir/#\~/$HOME}"
    conf_dir="${conf_dir/#\~/$HOME}"
    conf_file="${conf_file/#\~/$HOME}"

    # Validate
    if ! command -v "$editor" >/dev/null 2>&1; then
        echo "WARNING: could not find the editor '$editor' in system"
    fi

    local contents=$(
        cat <<-EOF
			JOURNALSCRIPT_EDITOR="$editor"
			JOURNALSCRIPT_JOURNAL_DIR="$journal_dir"
			JOURNALSCRIPT_DEFAULT_JOURNAL="$default_journal"
			JOURNALSCRIPT_GROUP_BY="$group_by"
			JOURNALSCRIPT_SYNC_BACKUP=""
		EOF
    )

    # If print then write contents to stdout and exit early
    # No need for feedback because there are no side effects
    if [[ "$1" == "--print" ]]; then
        printf "%s" "$contents"
        exit 0
    fi

    # User feedback
    local new_dirs=()
    local new_files=()
    local overriden_files=()
    if ! test -d "$journal_dir"; then new_dirs+=("$journal_dir"); fi
    if ! test -d "$conf_dir"; then new_dirs+=("$conf_dir"); fi
    if ! test -d "$conf_dir/hooks"; then new_dirs+=("$conf_dir/hooks"); fi
    if ! test -d "$conf_dir/hooks/backup.d"; then new_dirs+=("$conf_dir/hooks/backup.d"); fi
    if ! test -d "$conf_dir/hooks/sync.d"; then new_dirs+=("$conf_dir/hooks/sync.d"); fi

    if test -f "$conf_file"; then overriden_files+=("$conf_file"); else new_files+=("$conf_file"); fi

    if [[ "${#new_dirs[@]}" -gt 0 ]]; then
        printf "The following directories will be created:\n"
        for dir in "${new_dirs[@]}"; do
            printf "  %s\n" "$dir"
        done
    fi
    if [[ "${#new_files[@]}" -gt 0 ]]; then
        printf "The following files will be created:\n"
        for file in "${new_files[@]}"; do
            printf "  %s\n" "$file"
        done
    fi
    if [[ "${#overriden_files[@]}" -gt 0 ]]; then
        printf "The following files will be overriden:\n"
        for file in "${overriden_files[@]}"; do
            printf "  %s\n" "$file"
        done
    fi

    local confirm
    read -p "Do you wish to continue? [y/n]:" confirm
    [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0

    # Execute: Write config directory and file
    for dir in "${new_dirs[@]}"; do
        [[ -n "$dir" ]] && mkdir -p "$dir"
    done

    printf "%s" "$contents" >"${conf_file}"
    printf "Done\n"
}

_help_write() {
    cat >&1 <<-EOF

		Usage: journal write [options] [journal] 

		Writes a new entry to a journal.  If no journal is provided, it writes to
		the default journal. Each journal entry corresponds to a day.

		Journals are stored as directories and journal entries are stored in files
		whithin those directories. Journal creates new files if they dont exist, and
		it opens the file with today's entry with your editor of choice.

		Options:
		  --help        Prints this message and quits

		Examples:
		    journal                     Writes an entry to the default journal
		    journal my-journal          Writes an entry to 'my-jouranl'
		    journal write my-journal    Writes an entry to 'my-journal'
	EOF
}

# File name is the creation name by date based on CADENCE
_file_name() {
    case "$JOURNALSCRIPT_GROUP_BY" in
    DAY)
        date +%Y-%m-%d
        ;;
    MONTH)
        date +%Y-%m
        ;;
    YEAR)
        date +%Y
        ;;
    esac
}

# tests file whether it is outdated and a new file should be created, or whether
# the file is current, and contents shoudl be appended to it. This is based on the
# configured CADENCE
is_outdated_file() {
    local file_date="${1%.*}" # removes file extension from name

    local file_year="${file_date::4}"
    local year=$(date +%Y)
    [[ $year -gt $file_year ]] && return 0

    local file_month="${file_date:5:2}"
    local month=$(date +%m)
    [[ "$JOURNALSCRIPT_GROUP_BY" != "YEAR" ]] && [[ -n $file_month ]] &&
        [[ $month -gt $file_month ]] && return 0

    local file_day="${file_date:8:2}"
    local day="$(date +%d)"
    [[ "$JOURNALSCRIPT_GROUP_BY" != "MONTH" ]] && [[ -n $file_day ]] &&
        [[ $day -gt $file_day ]] && return 0

    return 1
}

# Writes journal entries.
#
# In case of new entires cretes the a new journal entry. And in case of
# existing entres it opens the existng entry.
# It populates new etries with a timestamp and it invokes open and backup hooks
# for editing and saving journal entries.
# _write accepts up to one argument which is the journal name
# Or no arguments, in such case the journal name become _DEFAILT_JOURNAL_NAME
_write() {
    # The command deosnt accept more than 1 argumetn. Error out in such case
    if [[ ${#@} -gt 1 ]]; then
        _fail "'write' command supports up to 1 argument."
    fi
    # fail if JOURNALSCRIPT_JOURNAL_DIR does not exist
    if [[ -z "$JOURNALSCRIPT_JOURNAL_DIR" ]]; then
        _fail "JOURNALSCRIPT_JOURNAL_DIR is not set"
    fi
    # if no argument (journal name), then default to the default journal
    local journal_name="${1:-$JOURNALSCRIPT_DEFAULT_JOURNAL}"
    # directory that hosts all the entries of the journal
    local journal_dir="$JOURNALSCRIPT_JOURNAL_DIR/$journal_name"

    # if the journal directory doesnt not exist, notify user and create it if
    # the user agrees
    if ! test -d "$journal_dir"; then
        read -p "The journal directory '$journal_dir' doesn't exist. Do you wish to create it (y/n):" confirm
        [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0
        mkdir -p "$journal_dir"
    fi

    # TODO inform of sync [SUCCESS|FAILURE|NONE]
    # embed git hook
    if [[ "git" == "$JOURNALSCRIPT_SYNC_BACKUP" ]]; then
        if is_git_repo "$journal_dir"; then
            git -C "$journal_dir" pull --rebase --quiet
        fi
    else
        _sync_journal
    fi

    # the most recent file in journal directory
    local file=$(ls -Art1 "${journal_dir}" | tail -n 1)
    local file_fp="${journal_dir}/$file"
    local info_msg=""
    # test if file is current or outdated, if outdated a new one needs to be created
    if [ ! -f "$file_fp" ] || [ -f "$file_fp" ] && is_outdated_file "$file"; then
        # creates new file
        file="$(_file_name).md"
        # full path the journal entry file to crete/edit
        file_fp="${journal_dir}/$file"
        touch "$file_fp"
        info_msg="New file '$file' added to the journal '$journal_name'"
        printf "==> %s\n" "$info_msg"
    fi
    # if file does not have today's entry
    if ! grep -q "$(date +'%a %b %d %Y')" "$file_fp"; then
        # Add new entry to existing file
        printf "\n\n#####%s\n" "$(date +'%a %b %d %Y, %I:%M %p %Z')" >>"$file_fp"
        info_msg="New entry in file '$file' added to the journal '$journal_name'"
        printf "==> %s\n" "$info_msg"
    fi

    $JOURNALSCRIPT_EDITOR "$file_fp"

    # embed git backup
    if [[ "git" == "$JOURNALSCRIPT_SYNC_BACKUP" ]]; then
        #  if it is a git repo and there are changes.
        if is_git_repo "$journal_dir" && ! quiet_git -C "$journal_dir" diff --exit-code -s "$file_fp"; then
            echo "-C $journal_dir add $file_fp"
            quiet_git -C "$journal_dir" add "$file_fp" &&
                quiet_git -C "$journal_dir" commit --allow-empty-message -m "$info_msg" &&
                quiet_git -C "$journal_dir" push
        fi
    else
        _backup_journal
    fi
}

_main() {
    if [[ ${_PRINT_VERSION} -eq 1 ]]; then
        printf "%s\n" "$_ME $_VERSION"
        exit 0
    fi
    if [[ ${_PRINT_HELP} -eq 1 ]]; then
        _help "$_COMMAND"
        exit 0
    fi
    # If $_COMMAND is not provided, then set to 'write' (default command)
    if [[ -z "$_COMMAND" ]]; then
        _COMMAND=$_COMMAND_WRITE
    fi
    $_COMMAND "${_COMMAND_ARGUMENTS[@]}"
}

################################################################################
# Run Program                                                                  #
################################################################################
# Call the `_main` function after everything has been defined.
_main
