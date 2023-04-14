#!/bin/env bash
#
# Interative script / wizard to asssit on the creation of new configuration
# file for journalscript
#
set -e
################################################################################
# ENV                                                                          #
#####################################"###########################################
# Inherent from caller
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-}
JOURNALSCRIPT_JOURNAL_DIR=${JOURNALSCRIPT_JOURNAL_DIR:-}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-}
_JOURNALSCRIPT_CONF_DIR=${_JOURNALSCRIPT_CONF_DIR:-}
JOURNALSCRIP_DEFAULT_JOURNAL=${JOURNALSCRIP_DEFAULT_JOURNAL:-}

################################################################################
# Functions                                                                    #
################################################################################
# Checks argument is stdout or STDOUT
is_stdout() {
    [[ "$1" == "--print" ]]
}

################################################################################
# Read (prompt) configuration preferences from user                            #
################################################################################
read -p "Journal entry's file format [txt|md|etc] ($JOURNALSCRIPT_FILE_TYPE):" file_type
read -p "Editor ($JOURNALSCRIPT_EDITOR):" editor
read -p "Journal entry location [path/to/directory] ($JOURNALSCRIPT_JOURNAL_DIR):" journal_dir
JOURNALSCRIPT_JOURNAL_DIR=${journal_dir:-$JOURNALSCRIPT_JOURNAL_DIR}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-"$JOURNALSCRIPT_JOURNAL_DIR/.journalscript/templates"}
read -p "Templates location [path/to/directory] ($JOURNALSCRIPT_TEMPLATE_DIR):" template_dir
read -p "Would you like to set a default journal [optional] ($JOURNALSCRIPT_DEFAULT_JOURNAL):" default_journal
read -p "Where do you wish to store the configuration [path/to/directory] ($_JOURNALSCRIPT_CONF_DIR):" conf_dir

# Default values if no user input
_JOURNALSCRIPT_CONF_DIR=${conf_dir:-$_JOURNALSCRIPT_CONF_DIR}
_JOURNALSCRIPT_CONF_FILE="${_JOURNALSCRIPT_CONF_DIR}/journalscript.env"
JOURNALSCRIPT_FILE_TYPE=${file_type:-$JOURNALSCRIPT_FILE_TYPE}
JOURNALSCRIPT_EDITOR=${editor:-$JOURNALSCRIPT_EDITOR}
JOURNALSCRIPT_TEMPLATE_DIR=${template_dir:-$JOURNALSCRIPT_TEMPLATE_DIR}
JOURNALSCRIPT_DEFAULT_JOURNAL=${default_journal:-$JOURNALSCRIPT_DEFAULT_JOURNAL}

unset file_type editor journal_dir template_dir conf_file

################################################################################
# Validate                                                                     #
################################################################################
if ! command -v "$JOURNALSCRIPT_EDITOR" >/dev/null 2>&1; then
    echo "WARNING: could not find the editor '$JOURNALSCRIPT_EDITOR' in system"
fi

_contents=$(
    cat <<-EOF
		JOURNALSCRIPT_FILE_TYPE="$JOURNALSCRIPT_FILE_TYPE"
		JOURNALSCRIPT_EDITOR="$JOURNALSCRIPT_EDITOR"
		JOURNALSCRIPT_JOURNAL_DIR="$JOURNALSCRIPT_JOURNAL_DIR"
		JOURNALSCRIPT_TEMPLATE_DIR="$JOURNALSCRIPT_TEMPLATE_DIR"
		JOURNALSCRIPT_DEFAULT_JOURNAL="$JOURNALSCRIPT_DEFAULT_JOURNAL"
	EOF
)

# If print then write contents to stdout and exit early
# No need for feedback because there are no side effects
if is_stdout; then
    printf "%s" "$_contents"
    exit 0
fi

################################################################################
# User feedback                                                                #
################################################################################
NEW_DIRS=()
if ! test -d "$JOURNALSCRIPT_JOURNAL_DIR"; then
    NEW_DIRS+=("$JOURNALSCRIPT_JOURNAL_DIR")
fi
if ! test -d "$JOURNALSCRIPT_TEMPLATE_DIR"; then
    NEW_DIRS+=("$JOURNALSCRIPT_TEMPLATE_DIR")
fi
if ! test -d "$_JOURNALSCRIPT_CONF_DIR"; then
    NEW_DIRS+=("$_JOURNALSCRIPT_CONF_DIR")
fi
# TODO: Files need to expand to full path
if [[ "${#NEW_DIRS[@]}" -eq 0 ]]; then
    printf "The following direcotries will be created:\n"
    for dir in "${NEW_DIRS[@]}"; do
        printf "  %s\n" "$dir"
    done
fi
if ! test -f "$_JOURNALSCRIPT_CONF_FILE"; then
    printf "The following files will be created:\n"
    printf "  %s\n" "$_JOURNALSCRIPT_CONF_FILE"
else
    # TODO: make a WARNING
    printf "The following files will be overriden:\n"
    printf "  %s\n" "$_JOURNALSCRIPT_CONF_FILE"
fi

read -p "Do you wish to continue? [y/n]:" confirm
[[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0

################################################################################
# Execute: Write config directory and file                                     #
################################################################################
mkdir -p "$JOURNALSCRIPT_JOURNAL_DIR"
mkdir -p "$JOURNALSCRIPT_TEMPLATE_DIR"
mkdir -p "$_JOURNALSCRIPT_CONF_DIR"

printf "%s" "$_contents" >"${_JOURNALSCRIPT_CONF_FILE}"
printf "Done\n"
unset _contents confirm
