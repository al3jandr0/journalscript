#/usr/bin/env bash

# bash-completion for journal command
function _homes() {
    local journal_dirs=( "$HOME/repos/journal/$2"*/ )
    local journal_names=( "${journal_dirs[@]%\/}" )
    [[ -d ${journal_names[0]} ]] && COMPREPLY=( "${journal_names[@]##*/}" )
}
complete -F _journal journal

