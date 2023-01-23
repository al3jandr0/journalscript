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
EDITOR="${EDITOR:-vi}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"

# Journalsscript env

# Look for configuration in the following locations in order
# 1. Already specified in Env
# 2. $XDG_CONFIG_HOME/journalscript/journalscript.env
# 3. $HOME/.config/journalscript/journalscript.env
# 4. $HOME/.journalscript/journalscript.env
_default_config_dir="$HOME/.journalscript"
if test -d "$XDG_CONFIG_HOME/journalscript"; then
    _default_config_dir="$XDG_CONFIG_HOME/journalscript"
fi
JOURNALSCRIPT_CONF_FILE_DIR=${JOURNALSCRIPT_CONF_FILE_DIR:-$_default_config_dir}
JOURNALSCRIPT_CONF_FILE_NAME=${JOURNALSCRIPT_CONF_FILE_NAME:-"journalscript.env"}
unset _default_config_dir

# Configuration env vars are used in the following order of priority
# 1. ENV
# 2. Configuration file
# 3. Defaults

# 1 & 2. Source configuration file, if it exists
if test -f "$JOURNALSCRIPT_CONF_FILE_DIR/$JOURNALSCRIPT_CONF_FILE_NAME"; then
    # foe each line in the configuration file
    while read line; do
        # ignore comments
        [[ "$line" =~ ^#.*$ ]] && continue
        # each line follows the format: <name>=<value>
        readarray -t -d '=' var < <(printf '%s' "$line")
        # expand values
        _expanded_value=$(eval printf '%s' "${var[1]}")
        # set configuration file variable if it is not already set in env
        declare "${var[0]}"="${!var[0]:-$_expanded_value}"
    done < "$JOURNALSCRIPT_CONF_FILE_DIR/$JOURNALSCRIPT_CONF_FILE_NAME"
fi

# 3. Set default values if not in configuration file or already set in env
JOURNALSCRIPT_FILE_TYPE=${JOURNALSCRIPT_FILE_TYPE:-"txt"}
JOURNALSCRIPT_EDITOR=${JOURNALSCRIPT_EDITOR:-"$EDITOR"}
JOURNALSCRIPT_DATA_DIR=${JOURNALSCRIPT_DATA_DIR:-"$XDG_DOCUMENTS_DIR"}
JOURNALSCRIPT_TEMPLATE_DIR=${JOURNALSCRIPT_TEMPLATE_DIR:-\
"$JOURNALSCRIPT_DATA_DIR/.journalscript/templates"}

################################################################################
# Functions                                                                    #
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

_configure() {
    local args="$@"
    # Accept only up to 1 argument
    if [[ "${#args[@]}" -gt 1 ]]; then
        echo "ERROR. configuration command supports up to 1 argument"
    fi
    # if no arguments, then default to 'show' sub-command
    if [[ ${#args[@]} -eq 0 ]]; then
        args+="show"
    fi
    # Run sub commands:
    # config-show.
    if [[ "${args[0]}" == "show" ]]; then
		cat <<-EOF
		JOURNALSCRIPT_CONF_FILE_DIR="${JOURNALSCRIPT_CONF_FILE_DIR}"
		JOURNALSCRIPT_CONF_FILE_NAME="${JOURNALSCRIPT_CONF_FILE_NAME}"
		JOURNALSCRIPT_FILE_TYPE="${JOURNALSCRIPT_FILE_TYPE}"
		JOURNALSCRIPT_EDITOR="${JOURNALSCRIPT_EDITOR}"
		JOURNALSCRIPT_DATA_DIR="${JOURNALSCRIPT_DATA_DIR}"
		JOURNALSCRIPT_TEMPLATE_DIR="${JOURNALSCRIPT_TEMPLATE_DIR}"
		EOF
    # config-init
    elif [[ "${args[0]}" == "init" ]]; then
        . init_configuration.sh
    # unknown command.
    else
        echo "ERROR. Unsupported argument of 'configure'."
        echo "See journalscript configure --help for supported options"
    fi
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
    $_COMMAND "${_COMMAND_ARGUMENTS[@]}"
}

################################################################################
# Run Program                                                                  #
################################################################################
# Call the `_main` function after everything has been defined.
_main
