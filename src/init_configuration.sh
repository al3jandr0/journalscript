#!/bin/env bash
#
# Interative script / wizard to asssit on the creation of new configuration 
# file for journalscript
#
################################################################################
# ENV                                                                          #
################################################################################
JOURNALSCRIPT_CONF_FILE_DIR=${JOURNALSCRIPT_CONF_FILE_DIR:-}
JOURNALSCRIPT_CONF_FILE_NAME=${JOURNALSCRIPT_CONF_FILE_NAME:-}
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-}
JOURNALSCRIPT_DATA_DIR=${JOURNALSCRIPT_DATA_DIR:-}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-}
_JOURNALSCRIPT_CONF_FILE="$JOURNALSCRIPT_CONF_FILE_DIR/$JOURNALSCRIPT_CONF_FILE_NAME"

################################################################################
# Functions                                                                    #
################################################################################
# Checks argument isnt stdout and it isnt the default "<empty>/<empty>"
is_file() {
    [[ "${#1}" -gt 1 && "$1" != [sS][tT][dD][oO][uU][tT] ]]
}

################################################################################
# Read (prompt) configuration preferences from user                            #
################################################################################
read -p "\$JOURNALSCRIPT_FILE_TYPE. Journal entry's file format ($JOURNALSCRIPT_FILE_TYPE):" file_type
read -p "\$JOURNALSCRIPT_EDITOR. Editor ($JOURNALSCRIPT_EDITOR):" editor
read -p "\$JOURNALSCRIPT_DATA_DIR. Journal entry location [path/to/directory] ($JOURNALSCRIPT_DATA_DIR):" data_dir
read -p "\$JOURNALSCRIPT_TEMPLATE_DIR. Templates location [path/to/directory] ($JOURNALSCRIPT_TEMPLATE_DIR):" template_dir
read -p "Configuration file [path/to/file|stdout] ($_JOURNALSCRIPT_CONF_FILE):" conf_file

# Default values if no user input
_JOURNALSCRIPT_CONF_FILE=${conf_file:-$_JOURNALSCRIPT_CONF_FILE}
if is_file "${_JOURNALSCRIPT_CONF_FILE}"; then
    JOURNALSCRIPT_CONF_FILE_DIR="${_JOURNALSCRIPT_CONF_FILE%/*}"
fi
JOURNALSCRIPT_FILE_TYPE=${file_type:-$JOURNALSCRIPT_FILE_TYPE}
JOURNALSCRIPT_EDITOR=${editor:-$JOURNALSCRIPT_EDITOR}
JOURNALSCRIPT_DATA_DIR=${data_dir:-$JOURNALSCRIPT_DATA_DIR}
JOURNALSCRIPT_TEMPLATE_DIR=${template_dir:-$JOURNALSCRIPT_TEMPLATE_DIR}

unset file_type editor data_dir template_dir conf_file

################################################################################
# Validate                                                                     #
################################################################################
if ! command -v "$JOURNALSCRIPT_EDITOR" > /dev/null 2>&1; then
    echo "WARNING: could not find editor '$JOURNALSCRIPT_EDITOR' in system. Verify it is installed"
fi
if ! test -d "$JOURNALSCRIPT_DATA_DIR"; then
    echo "Journals directory $JOURNALSCRIPT_DATA_DIR will be created"
fi
if ! test -d "$JOURNALSCRIPT_TEMPLATE_DIR"; then
    echo "Templates directory $JOURNALSCRIPT_TEMPLATE_DIR will be created"
fi
if is_file "${_JOURNALSCRIPT_CONF_FILE}"; then
    if ! test -d "$JOURNALSCRIPT_CONF_FILE_DIR"; then
        echo "Configuration directory $JOURNALSCRIPT_CONF_FILE_DIR will be created"
    fi
    if test -f "${_JOURNALSCRIPT_CONF_FILE}"; then
        echo "The configuration file ${_JOURNALSCRIPT_CONF_FILE} will be overriden."
    else
        echo "A new configuration file ${_JOURNALSCRIPT_CONF_FILE} will be created"
    fi
fi
################################################################################
# Execute: Write config directory and file                                     #
################################################################################
read -p "Confirm changes? [y/n]:" confirm
[[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0

mkdir -p "$JOURNALSCRIPT_DATA_DIR"
mkdir -p "$JOURNALSCRIPT_TEMPLATE_DIR"
mkdir -p "$JOURNALSCRIPT_CONF_FILE_DIR"

_contents=$(cat <<-EOF
JOURNALSCRIPT_FILE_TYPE="$JOURNALSCRIPT_FILE_TYPE"
JOURNALSCRIPT_EDITOR="$JOURNALSCRIPT_EDITOR"
JOURNALSCRIPT_DATA_DIR="$JOURNALSCRIPT_DATA_DIR"
JOURNALSCRIPT_TEMPLATE_DIR="$JOURNALSCRIPT_TEMPLATE_DIR"
EOF
)
if [[ ${_JOURNALSCRIPT_CONF_FILE} == [sS][tT][dD][oO][uU][tT] ]]; then
    printf "%s" "$_contents" 
else
    printf "%s" "$_contents" > "${_JOURNALSCRIPT_CONF_FILE}"
fi
unset _contents confirm
