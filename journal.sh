#!/bin/bash
FILE_TYPE="md"
EDITOR="nvim"
#DATA_DIR="$HOME/repos/journal"
DATA_DIR="/tmp"

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
            echo "journal name passed $i"
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
        if ! test -f $filename; then
            write_template "$JOURNAL" "$filename"
        fi
        $EDITOR $filename
        exit 0
        ;;
esac
