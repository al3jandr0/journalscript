#!/bin/env bash

GIF_DIR="resources"
export JOURNALSCRIPT_SYNC_BACKUP=""
export JOURNALSCRIPT_EDITOR="vi"
export JOURNALSCRIPT_JOURNAL_DIR="/home/alej/Documents/journals/"

######################################################################
# GIF: journal                                                       #
######################################################################
# Prepare
rm -rf "${JOURNALSCRIPT_JOURNAL_DIR}"
# VHS
vhs journal.tape --output ${GIF_DIR}/journal.gif
# Cleanup
rm -rf "${JOURNALSCRIPT_JOURNAL_DIR}"
exit 0
######################################################################
# GIF: journal write my-other-journal                                #
######################################################################
# Prepare
JOURNAL="my-other-journal"
rm -rf "${JOURNALSCRIPT_JOURNAL_DIR}${JOURNAL}"
mkdir -p "${JOURNALSCRIPT_JOURNAL_DIR}${JOURNAL}"
printf "##### Thu Jan 24 2024, 12:14 AM EST\n\nI'm you from the past." \
    >"${JOURNALSCRIPT_JOURNAL_DIR}${JOURNAL}/2024.md"
# VHS
vhs journal_write_custom.tape --output ${GIF_DIR}/journal_write_custom.gif
# Cleanup
rm -rf "${JOURNALSCRIPT_JOURNAL_DIR}${JOURNAL}"
######################################################################
# GIF: journal configure init                                        #
######################################################################
# Prepare
rm -rf ~/.config/journalscript/
# VHS
vhs journal_configure_init.tape --output ${GIF_DIR}/configure_init.gif
# Cleanup
rm -rf ~/.config/journalscript/
######################################################################
# GIF: JOURNALSCRIPT_SYNC_BACKUP="¯\_(ツ)_/¯" journal configure show #
######################################################################
# Prepare
rm -rf ~/.config/journalscript/
# VHS
vhs journal_override_env_var.tape --output ${GIF_DIR}/override_env_var.gif
# Cleanup
rm -rf ~/.config/journalscript/

unset JOURNALSCRIPT_SYNC_BACKUP
unset JOURNALSCRIPT_EDITOR
unset JOURNALSCRIPT_JOURNAL_DIR
