#!/bin/bash
FILE_TYPE="md"
EDITOR="nvim"
DATA_DIR="$HOME/repos/journal"
#DATA_DIR="/tmp"
TEMPLATE_DIR="$DATA_DIR/.journalscrript/templates"
SUB_COMAND_EDIT="edit"
SUB_COMMAND_CREATE="create"

# read journal-name

for i in "$@"; do
    case $i in
        --help)
			cat <<-EOF
			Usage: journal [JOURNAL_NAME]
			A handy script to write journals.
			    ls		displays journals stored in JOURNAL_DATA_DIR 
			    --help	displays this help and exit
			EOF
            exit 0
            ;;
        ls)
            COMMAND="ls"
            ;;
        *)
            COMMAND="create-edit"
            JOURNAL="$i"
            #echo "journal name passed $i"
            ;;
    esac
    shift
done

write_template() {
    local journalName="$1"
    local journalEntryFile="$2"
    local template="$TEMPLATE_DIR/$journalName"

    if test -f "$template"; then
        while read line; do
            echo "echo \"$line\"" | bash >> "$journalEntryFile"
        done < "$template"
    else
        # default template is a date stamp
        echo "$(date)" > "$journalEntryFile"

backup_file() {
    local commit_msg=""
    if [ "$2" = "$SUB_COMMAND_CREATE" ]; then
        commit_msg="Adds entry"
    else
        commit_msg="Edits entry"
    fi
    git -C "$DATA_DIR" add "$1" && git -C "$DATA_DIR" commit -m "$commit_msg" && git -C "$DATA_DIR" push
}

open_files() {
    local files=("$@")
    if [ "$EDITOR" = "nvim" ]; then
        nvim -o "${files[@]}"
    else
        $EDITOR "${file[0]}"
    fi
}

today=$(date +%Y-%m-%d)
filename="$DATA_DIR/$JOURNAL/$today.$FILE_TYPE"

case $COMMAND in
    ls)
        # TODO: filter ignored files
        ls "$DATA_DIR"
        exit 0
        ;;
    create-edit)
        if ! test -d "$DATA_DIR/$JOURNAL"; then
            echo "Failed to create journal entry. Journal $JOURNAL does not exists in $DATA_DIR" 1>&2
            exit 1
        fi
        SUB_COMMAND="$SUB_COMMAND_EDIT"
        if ! test -f $filename; then
            SUB_COMMAND="$SUB_COMMAND_CREATE"
            write_template "$JOURNAL" "$filename"
        fi
        readarray -t filesToOpen < <(ls -tA $DATA_DIR/$JOURNAL/* | head -n2) # 2 most recent files
        open_files "${filesToOpen[@]}" && backup_file "$filename" "$SUB_COMMAND"
        exit 0
        ;;
esac
