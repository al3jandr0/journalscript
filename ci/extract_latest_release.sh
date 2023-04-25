#!/usr/bin/env bash
declare -i f
f=0
REGEX="^## "
while read -r l; do
    [[ -z "$l" ]] && continue
    [[ "$l" =~ $REGEX ]] && if [[ $f -eq 0 ]]; then f=1; else exit 0; fi
    [[ ! "$l" =~ $REGEX && $f -eq 1 ]] && printf "%s\n" "$l"
done <"${1:-/dev/stdin}"
