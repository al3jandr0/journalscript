#!/bin/env bash
################################################################################
# Provided variables                                                           #
################################################################################
# Ignores existing Env vars since the goal is to generate new configuration
# TODO: allow to configure the directory and fime name to suppoer .env
_JS_CONF_FILE_NAME="journalscript.env"
_JS_CONF_DIR="$HOME/.config/journalscript"
JS_CONF_FILE_TYPE="md"
JS_CONF_EDITOR="typora"
JS_CONF_DATA_DIR="$HOME/repos/journal"
JS_CONF_TEMPLATE_DIR="$JS_CONF_DATA_DIR/.journalscript/templates"

################################################################################
# Read (prompt) configuration preferences from user                            #
################################################################################
read -p "Journal file format ($JS_CONF_FILE_TYPE):" p_file_type
read -p "Editor ($JS_CONF_EDITOR):" p_editor
read -p "Journal directory ($JS_CONF_DATA_DIR):" p_data_dir
read -p "Journal templates directory ($JS_CONF_TEMPLATE_DIR):" p_tempalte_dir

# Default values if no user input
file_type=${p_file_type:-$JS_CONF_FILE_TYPE}
editor=${p_editor:-$JS_CONF_EDITOR}
data_dir=${p_pdata_dir:-$JS_CONF_DATA_DIR}
template_dir=${p_tempalte_dir:-$JS_CONF_TEMPLATE_DIR}

################################################################################
# Validate                                                                     #
################################################################################
if ! command -v "$editor" > /dev/null 2>&1; then
    echo "WARNING: could not find editor in system. Verify it is installed"
fi
if ! test -d "$data_dir"; then
    echo "Journals directory $data_dir will be created"
fi
if ! test -d "$template_dir"; then
    echo "Templates directory $data_dir will be created"
fi
if ! test -d "$_JS_CONF_DIR"; then
    echo "Configuration directory $_JS_CONF_DIR will be created"
fi
if test -f "$_JS_CONF_DIR/$_JS_CONF_FILE_NAME"; then
    echo "The configuration file $_JS_CONF_DIR/$_JS_CONF_FILE_NAME will be overriden."
else
    echo "A new configuration file $_JS_CONF_DIR/$_JS_CONF_FILE_NAME will be created"
fi

################################################################################
# Execute: Write config directory and file                                     #
################################################################################
read -p "Conform changes? [y/n]:" confirm
[[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0

mkdir -p "$data_dir"
mkdir -p "$template_dir"
mkdir -p "$_JS_CONF_DIR"

# TODO:  write configuration to file
cat <<-EOF > "$_JS_CONF_DIR/$_JS_CONF_FILE_NAME"
JS_CONF_FILE_TYPE="$file_type"
JS_CONF_EDITOR="$editor"
JS_CONF_DATA_DIR="$data_dir"
JS_CONF_TEMPLATE_DIR="$template_dir"
EOF
