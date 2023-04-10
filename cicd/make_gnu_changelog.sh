#!/bin/env bash
#
###############################################################################
#  Inputs                                                                     #
###############################################################################
FILE=${1:-"CHANGELOG.md"}
SOURCE_SCRIPT=${2:-"src/journal.sh"}

###############################################################################
#  Outputs                                                                    #
###############################################################################
# prints converted changelog to stdout

###############################################################################
# ENV                                                                         #
###############################################################################
PREV_READ_BLOCK="FOREWORD"
# SECTION CONTEXT
CONTEXT_VERSION=""
CONTEXT_DATE=""
name_version=($(bash $SOURCE_SCRIPT -v))
PACKAGE="${name_version[0]}"
VERSION="${name_version[1]}"

markdown_type() {
    local line_begining="$1"
    if [[ "#" == "$line_begining" ]]; then
        echo "HEADER1"
    elif [[ "##" == "$line_begining" ]]; then
        echo "HEADER2"
    elif [[ "###" == "$line_begining" ]]; then
        echo "HEADER3"
    elif [[ "-" == "$line_begining" ]]; then
        echo "LIST_ITEM"
    else
        echo "TEXT"
    fi
}

get_block() {
    local prev_block="$1"
    local line_type="$2"
    if [[ $prev_block == "FOREWORD" ]]; then
        if [[ $line_type == "HEADER2" ]]; then
            echo "RELEASE_HEADER"
        else
            echo "FOREWORD"
        fi
    elif [[ $prev_block =~ "RELEASE" ]]; then
        if [[ $line_type == "HEADER2" ]]; then
            echo "RELEASE_HEADER"
        elif [[ $line_type == "HEADER3" ]]; then
            echo "RELEASE_SECTION"
        elif [[ $line_type == "LIST_ITEM" ]]; then
            echo "RELEASE_LIST_ITEM"
        fi
    fi
}

filter_block() {
    local prev_block="$1"
    local current_block="$2"
    if [[ $current_block == "FOREWORD" ]]; then
        echo "IGNORE"
    elif [[ $current_block == "RELEASE_SECTION" ]]; then
        echo "IGNORE"
    elif [[ $prev_block =~ "RELEASE" && $current_block == "RELEASE_HEADER" ]]; then
        echo "FOOTER RELEASE_HEADER"
    else
        echo "$current_block"
    fi
}

HEADER_REGEX="## \+\[\?v\([0-9]\+\.[0-9]\+\.[0-9]\+\)\]\? - \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)"
set_context() {
    local block="$1"
    local line="$2"
    if [[ $block == "RELEASE_HEADER" ]]; then
        if [[ "$line" =~ UNRELEASED|Unreleased ]]; then
            CONTEXT_VERSION="$VERSION"
            CONTEXT_DATE=$(date +%Y-%M-%d)
        else
            CONTEXT_VERSION=$(printf "%s" "$line" | sed -n "s/$HEADER_REGEX/\1/p")
            CONTEXT_DATE=$(printf "%s" "$line" | sed -n "s/$HEADER_REGEX/\2/p")
        fi
    fi
}

write() {
    local write_block="$1"
    local line="$2"
    case $write_block in
    RELEASE_HEADER)
        printf "%s (%s) unstable; urgency=low\n\n" "$PACKAGE" "$CONTEXT_VERSION"
        ;;
    RELEASE_LIST_ITEM)
        printf "  %s\n" "${line/-/\*}"
        ;;
    FOOTER)
        # day-of-week, dd month yyyy hh:mm:ss +zzzz
        formated_date=$(date -d "$CONTEXT_DATE" "+%a, %d %b %Y %H:%M:%S %z")
        printf "\n %s %s <%s>  %s\n\n" "--" "alejandro" "contact.al3j@gmail.com" "$formated_date"
        ;;
    esac
}

while read -r line; do
    # Filter blank
    [[ -z "$line" ]] && continue
    line_type=$(markdown_type $line)
    read_block=$(get_block "$PREV_READ_BLOCK" "$line_type")
    write_blocks=($(filter_block "$PREV_READ_BLOCK" "$read_block"))
    set_context "$read_block" "$line"
    # debug
    #printf "%-20s %-20s %-20s %-20s |%s\n" "$line_type" "$read_block" "${write_blocks[0]}" "${write_blocks[1]}" "$line"
    for write_block in "${write_blocks[@]}"; do
        write "$write_block" "$line"
    done
    PREV_READ_BLOCK="$read_block"
done <"$FILE"

# closes the last release with a footer
write "FOOTER" ""
