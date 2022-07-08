#!/bin/bash
FILE_TYPE="md"
EDITOR="nvim"
DATA_DIR="$HOME/repos/journal"
#DATA_DIR="/tmp"
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
    local journalname="$1"
    local filename="$2"
    echo "writing to $filename"
    case $journalname in
        life)
echo "`date`

What are you grateful for

How do you feel well/bad/neutral ?

Do you wish to accomplish anything today ?

Are you looking forward anything in particular ?" > $filename 
        ;;
    esac
}

backup_file() {
    local commit_msg=""
    if [ "$2" = "$SUB_COMMAND_CREATE" ]; then
        commit_msg="Adds entry"
    else
        commit_msg="Edits entry"
    fi
    git add "$1" && git commit -m "$commit_msg" && git push
}

today=$(date +%Y-%m-%d)
filename="$DATA_DIR/$JOURNAL/$today.$FILE_TYPE"

case $COMMAND in
    ls)
        # todo: filter ignored files
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
        $EDITOR $filename && backup_file "$filename" "$SUB_COMMAND"
        exit 0
        ;;
esac
