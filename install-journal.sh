#!/usr/bin/env bash
# Handy installation script.  Run on repo's root directoty
# Copies journal executable script to a directory available in PATH
# Copies bash autocompelte scripts to a location bash can find it
#
install -T -m 755 ./journal.sh $HOME/.local/bin/journal
# Or if you dont have a ~/.local directory
# sudo install -T -m 755 ./journal.sh /usr/local/bin/journal

install -DT -m 755 journal.bash $HOME/.local/share/bash-completion/completions/journal
# Or if you dont have a ~/.local directory
# sudo install -T -m 755 journal.bash /etc/bash/bash-completion.d/journal
