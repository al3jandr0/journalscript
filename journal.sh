#!/usr/bin/env bash
# Dependencies
# - bash
# - git

COMMADN_LS="ls"
COMMAND_WRITE="write"
SUB_COMAND_WRITE_EDIT="edit"
SUB_COMMAND_WRITE_CREATE="create"

for i in "$@"; do
    case $i in
        --help)
			cat <<-EOF
			Usage: journal [CONFIG_JOURNAL_NAME]
			A handy script to write journals.
			    ls		displays journals stored in CONFIG_DATA_DIR 
			    --help	displays this help and exit
			EOF
            exit 0
            ;;
        ls)
            COMMAND="$COMMAND_LS"
            ;;
        *)
            COMMAND="$COMMAND_WRITE"
            JOURNAL="$i"
            ;;
    esac
    shift
done

# Configuration defaults
CONFIG_FILE_TYPE="md"
CONFIG_EDITOR="nvim"
# TODO:
# This cant be the default....
# You shoudl check when runnig the script!
# Is there a dependency with install ?
CONFIG_DATA_DIR="$HOME/repos/journal"
CONFIG_TEMPLATE_DIR="$CONFIG_DATA_DIR/.journalscrript/templates"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# Look for configuration in the following locations in order
# 1. $XDG_CONFIG_HOME/journalscript/journalscript.env
# 2. $HOME/.config/journalscript/journalscript.env
# 3. $HOME/.journalscript/journalscript.env
read_config() {
    if test -d "$XDG_CONFIG_HOME/journalscript"; then
        . $XDG_CONFIG_HOME/journalscript/journalscript.env
    elif test -d "$HOME/.journalscript"; then
        . $HOME/.journalscript/journalscript.env
    fi
}

write_template() {
    local journalName="$1"
    local journalEntryFile="$2"
    local template="$CONFIG_TEMPLATE_DIR/$journalName"

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
    git -C "$CONFIG_DATA_DIR" add "$1" && git -C "$CONFIG_DATA_DIR" commit -m "$commit_msg" && git -C "$CONFIG_DATA_DIR" push
}

# TODO: Fix files to remove the directory in position 0
open_files() {
    local files=("$@")
    if [[ "$CONFIG_EDITOR" == *"vim" ]]; then
        $CONFIG_EDITOR -o "${files[@]}"
    else
        $CONFIG_EDITOR "${files[0]}"
    fi
}

today=$(date +%Y-%m-%d)
filename="$CONFIG_DATA_DIR/$JOURNAL/$today.$CONFIG_FILE_TYPE"
case $COMMAND in
    ls)
        # TODO: filter ignored files
        ls "$CONFIG_DATA_DIR"
        exit 0
        ;;
    write)
        if ! test -d "$CONFIG_DATA_DIR/$JOURNAL"; then
            echo "Failed to create journal entry. Journal $JOURNAL does not exists in $CONFIG_DATA_DIR" 1>&2
            exit 1
        fi
        SUB_COMMAND="$SUB_COMMAND_EDIT"
        if ! test -f $filename; then
            SUB_COMMAND="$SUB_COMMAND_CREATE"
            write_template "$JOURNAL" "$filename"
        fi
        readarray -t filesToOpen < <(ls -tA $CONFIG_DATA_DIR/$JOURNAL/* | head -n2) # 2 most recent files
        # Enable a backup hook
        open_files "${filesToOpen[@]}" && backup_file "$filename" "$SUB_COMMAND"
        exit 0
        ;;
esac
