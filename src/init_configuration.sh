#!/bin/env bash
#
# Interative script / wizard to asssit on the creation of new configuration 
# file for journalscript
#
################################################################################
# ENV                                                                          #
#####################################"###########################################
# Inherent from caller
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-}
JOURNALSCRIPT_DATA_DIR=${JOURNALSCRIPT_DATA_DIR:-}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-}
_JOURNALSCRIPT_CONF_DIR=${_JOURNALSCRIPT_CONF_DIR:-}
JOURNALSCRIP_DEFAULT_JOURNAL=${JOURNALSCRIP_DEFAULT_JOURNAL:-}

################################################################################
# Functions                                                                    #
################################################################################
# Checks argument is stdout or STDOUT 
is_stdout() {
    [[ "$1" == [sS][tT][dD][oO][uU][tT] ]]
}

################################################################################
# Read (prompt) configuration preferences from user                            #
################################################################################
read -p "\$JOURNALSCRIPT_FILE_TYPE. Journal entry's file format ($JOURNALSCRIPT_FILE_TYPE):" file_type
read -p "\$JOURNALSCRIPT_EDITOR. Editor ($JOURNALSCRIPT_EDITOR):" editor
read -p "\$JOURNALSCRIPT_DATA_DIR. Journal entry location [path/to/directory] ($JOURNALSCRIPT_DATA_DIR):" data_dir
JOURNALSCRIPT_DATA_DIR=${data_dir:-$JOURNALSCRIPT_DATA_DIR}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-"$JOURNALSCRIPT_DATA_DIR/.journalscript/templates"}
read -p "\$JOURNALSCRIPT_TEMPLATE_DIR. Templates location [path/to/directory] ($JOURNALSCRIPT_TEMPLATE_DIR):" template_dir
# TODO: rewrite prompt to: 'where do you whis to write config [~|~/.config|stdout]?:
read -p "Would you like to set a default journal (optional) ($JOURNALSCRIPT_DEFAULT_JOURNAL):" default_journal
read -p "Configuration file [path/to/file|stdout] ($_JOURNALSCRIPT_CONF_DIR):" conf_dir

# Default values if no user input
_JOURNALSCRIPT_CONF_DIR=${conf_dir:-$_JOURNALSCRIPT_CONF_DIR}
_JOURNALSCRIPT_CONF_FILE="${_JOURNALSCRIPT_CONF_DIR}/journalscript.env"
JOURNALSCRIPT_FILE_TYPE=${file_type:-$JOURNALSCRIPT_FILE_TYPE}
JOURNALSCRIPT_EDITOR=${editor:-$JOURNALSCRIPT_EDITOR}
JOURNALSCRIPT_TEMPLATE_DIR=${template_dir:-$JOURNALSCRIPT_TEMPLATE_DIR}
JOURNALSCRIPT_DEFAULT_JOURNAL=${default_journal:-$JOURNALSCRIPT_DEFAULT_JOURNAL}

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
if ! is_stdout "${_JOURNALSCRIPT_CONF_DIR}"; then
    if ! test -d "$_JOURNALSCRIPT_CONF_DIR"; then
        echo "Configuration directory $JOURNALSCRIPT_CONF_DIR will be created"
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
mkdir -p "$_JOURNALSCRIPT_CONF_DIR"

_contents=$(cat <<-EOF
JOURNALSCRIPT_FILE_TYPE="$JOURNALSCRIPT_FILE_TYPE"
JOURNALSCRIPT_EDITOR="$JOURNALSCRIPT_EDITOR"
JOURNALSCRIPT_DATA_DIR="$JOURNALSCRIPT_DATA_DIR"
JOURNALSCRIPT_TEMPLATE_DIR="$JOURNALSCRIPT_TEMPLATE_DIR"
JOURNALSCRIPT_DEFAULT_JOURNAL="$JOURNALSCRIPT_DEFAULT_JOURNAL"
EOF
)
if is_stdout "${_JOURNALSCRIPT_CONF_DIR}"; then
    printf "%s" "$_contents" 
else
    printf "%s" "$_contents" > "${_JOURNALSCRIPT_CONF_FILE}"
fi
unset _contents confirm
