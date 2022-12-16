#!/usr/bin/env bash
# Dependencies
# - bash
# - git

################################################################################
# Parse Arguments                                                              #
################################################################################
COMMADN_LS="ls"
COMMAND_WRITE="write"
COMMAND_CONFIGURE="configure"
SUB_COMAND_WRITE_EDIT="edit"
SUB_COMMAND_WRITE_CREATE="create"

for i in "$@"; do
    case $i in
        --help)
			cat <<-EOF
			Usage: journal [JS_CONF_JOURNAL_NAME]
			A handy script to write journals.
			    ls			displays available journals 
                configure	initializes journalscript configuration
			    --help		displays this help and exit
			EOF
            exit 0
            ;;
        ls)
            COMMAND="$COMMAND_LS"
            ;;
        configure)
            COMMAND="$COMMAND_CONFIGURE"
            ;;
        *)
            COMMAND="$COMMAND_WRITE"
            JOURNAL="$i"
            ;;
    esac
    shift
done

################################################################################
# Set configuration                                                            #
################################################################################

# Configuration defaults
JS_CONF_FILE_TYPE="md"
JS_CONF_EDITOR="nvim"
JS_CONF_DATA_DIR="$HOME/repos/journal"
JS_CONF_TEMPLATE_DIR="$JS_CONF_DATA_DIR/.journalscrript/templates"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# Returns the full path to the configuration directory
config_dir() {
    if test -d "$XDG_CONFIG_HOME/journalscript"; then
        echo "$XDG_CONFIG_HOME/journalscript"
    elif test -d "$HOME/.journalscript"; then
        echo "$HOME/.journalscript"
    fi
}
# Look for configuration in the following locations in order
# 1. $XDG_CONFIG_HOME/journalscript/journalscript.env
# 2. $HOME/.config/journalscript/journalscript.env
# 3. $HOME/.journalscript/journalscript.env
_JS_CONF_DIR=config_dir
_JS_CONF_FILE_NAME="journalscript.env"
. $_JS_CONF_DIR/$_JS_CONF_FILE_NAME.env
# Re-set in case it is overriden by journalscript.env
_JS_CONF_DIR=config_dir

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
