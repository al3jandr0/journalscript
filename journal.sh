#!/usr/bin/env bash
# Dependencies
# - bash
# - git
#
# Descision:
# 1. If no journal exists, create new journal directory
#    And promp user for confirmation
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
COMMADN_LS="ls"
COMMAND_WRITE="write"
SUB_COMMAND_WRITE_EDIT="edit"
SUB_COMMAND_WRITE_CREATE="create"
COMMAND_CONFIGURE="configure"
SUB_COMMAND_CONFIGURE_SHOW="configure-show"
SUB_COMMAND_CONFIGURE_EDIT="configure-edit"

# TODO: figure out how to get rid of COMMAND_WRITE
_PRINT_HELP=0
_COMMAND=""
_COMMAND_ARGUMENTS=()
for __opt in "$@"; do
    case "${__opt}" in
        -h|--help)
            _PRINT_HELP=1
            ;;
        ls)
            _COMMAND="$COMMAND_LS"
            ;;
        configure)
            _COMMAND="$COMMAND_CONFIGURE"
            ;;
        write)
            _COMMAND="$COMMAND_WRITE"
            ;;
        *)
            # All unrecognized options are treated as arguments to the default
            # command
            _COMMAND_ARGUMENTS+=("${__opt}")
            ;;
    esac
    shift
done

main() {
    if ${_PRINT_HELP}; then
        _help "$_COMMAND"
    fi
    # If $_COMMAND is not provided, then set to 'write' (default command)
    if [[ -z "$_COMMAND" ]]; then
        _COMMAND=$_COMMAND_WRITE
    fi
    $_COMMAND "${_COMMAND_ARGUMENTS[@]}"
}

################################################################################
# Env                                                                          #
################################################################################
# Look for configuration in the following locations in order
# 1. Already specified in Env
# 2. $XDG_CONFIG_HOME/journalscript/journalscript.env
# 3. $HOME/.config/journalscript/journalscript.env
# 4. $HOME/.journalscript/journalscript.env

# Default config file location
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# Returns the full path to the configuration directory
default_config_location() {
    if test -d "$XDG_CONFIG_HOME/journalscript"; then
        echo "$XDG_CONFIG_HOME/journalscript"
    elif test -d "$HOME/.journalscript"; then
        echo "$HOME/.journalscript"
    fi
}
_default_config_dir=default_config_location
JOURNALSCRIPT_CONF_DIR="${JOURNALSCRIPT_CONF_DIR:-$_default_config_dir}"
JOURNALSCRIPT_CONF_FILE_NAME=${JOURNALSCRIPT_CONF_FILE_NAME:-"journalscript.env"}

# Source configuration file, if it exists
. $_JS_CONF_DIR/$_JS_CONF_FILE_NAME.env
if test -f $_JS_CONF_DIR/$_JS_CONF_FILE_NAME.env; then
    # prefix variables in configuration file with _CONF_FILE in order
    # to track their origin
    eval $(sed -nr 's/^([a-zA-Z_][a-zA-Z0-9_]+=.*)/_CONF_\1/p'\
        $_JS_CONF_DIR/$_JS_CONF_FILE_NAME.env)
fi

# Configuration vars are used in the following order of priority
# 1. ENV
# 2. Configuration file
# 3. Defaults
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-\
${_CONF_JOURNALSCRIPT_FILE_TYPE:-"md"}}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-
${_CONF_JOURNALSCRIPT_FILE_EDITOR:-"nvim"}}                 # Use system defaults
JOURNALSCRIPT_DATA_DIR=${JOURNALSCRIPT_DATA_DIR:-\
${_CONF_JOURNALSCRIPT_DATA_DIR:-"$HOME/repos/journal"}}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-\
${_CONF_JOURNALSCRIPT_TEMPLATE_DIR:-\
"$JOURNALSCRIPT_DATA_DIR/.journalscrript/templates"}}

# Unsets vars loaded from configuration file
unset _CONF_JOURNALSCRIPT_FILE_TYPE
unset _CONF_JOURNALSCRIPT_EDITOR
unset _CONF_JOURNALSCRIPT_DATA_DIR
unset _CONF_JOURNALSCRIPT_TEMPLATE_DIR

################################################################################
# Set configuration                                                            #
################################################################################

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
    if [ "$2" = "$SUB_COMMAND_CREATE" ]; then
        commit_msg="Adds entry"
    else
        commit_msg="Edits entry"
    fi
    git -C "$JS_CONF_DATA_DIR" add "$1" && git -C "$JS_CONF_DATA_DIR" commit -m "$commit_msg" && git -C "$JS_CONF_DATA_DIR" push
}

# TODO: Fix files to remove the directory in position 0
open_files() {
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


