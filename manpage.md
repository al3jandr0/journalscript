---
title: journalscript
section: 1
date: FEBRUARY 2023
header: Journalscript Manual
---

# NAME
journalscript - an interactive command line journaling tool.

# SYNOPSIS
journalscript

journalscript `COMMAND [ARG...]`

journalscript `[--help|-v|--verions]`

# DESCRIPTION

Journalscript is an interactive journaling tool for the command line.

It allows users to manage multiple journals, and it organizes them in directories.  Each directory corresponds to a journal.  Journal entries are stored in journal directories, and each entry is name as the current date (i.e. `2023-02-14.txt`).

Journalscript is highly configurable. However it requires no configuration upfront; its default behavior is sufficient and functional.

# OPTIONS
`-v`, `--version`\ 

: Prints version information and quits.

`--help`\ 

: Prints usage statement and quits.

# COMMANDS

## write [journal]

Writes a new entry to the journal.  If no journal is provided, it writes to the default journal. Journals are stored as directories and each journal entry is a file in the journal directory.  Each journal entry corresponds to a day, and their name is formated: YYYY-mm-dd.

The command creates new files if they don't exists, and it copies a template into them if template is configured.  Then it executes an open hook in order edit the the new journal entry (or an existing one). If no open hook exists, it defaults to use the launching the configured editor.  Once the user closes the editor, journalscript invokes a backup hook if any exists.

## configure [show|init]

Assists with the configuration of journalscript.  When configure is invoked with no arguments it defaults to show.

**show**\ 

Displays the configuration parameters (also referred as environment variables) along with  its assigned values, and quits.

**<u>init</u>**\ 

Launches an interactive wizard that helps the user setting up a journalscript configuration.

# RETURN VALUE

Returns 1 in case of error. Otherwise returns 0.

# ENVIRONMENT

JOURNALSCRIPT_FILE_TYPE\ 

: Sets the file name extension. Defaults `txt`

JOURNALSCRIPT_EDITOR\ 

: Sets the editor journalscript uses to open files.

JOURNALSCRIPT_JOURNAL_DIR\ 

: The directory where journals will be located. 

JOURNALSCRIPT_TEMPLATE_DIR\ 

: The directory where journalscript sources templates.

JOURNALSCRIPT_DEFAULT_JOURNAL\ 

: When journalscript wire is invoked without arguments, it writes to the default journal. Its default value is `life` 

# FILES

## Configuration
Journalscript behavior is customizable with via environment variables (see ENVIRONMENT).  Additionally, journalscript supports loading variables from a file named `journalscript.env`. So user can either modify the environment or write a `journalscript.env` in order to customize journalscript.  Journalscript looks for `journalscript.env` in two locations: first in `~/.config/journalscript/`, then in `~/.journalscript/`, and it only loads variables declared in the file that are not in the environment.  That is, variables in the environment are not overridden. 

Note: journalscript is not limited to loading journalscript-specific variables declared in file;  any variable in journalscript.env will be declared.  This makes journalscript.env a suitable place to declare additional variables used by hooks.

## Hooks
Hooks are bash scripts that Journalscript runs in order to open and backup journal entries, and they allow users to customize these two actions.  There are two types of hooks: open and backup. 

By default, journalscript opens a journal entry using the configured editor (JOURNALSCRIPT_EDITOR), and this behavior is overridden by open hooks. Open hook scripts must open the assigned journal entry by invoking an editor, and exit when the editor is closed. 

Backup hook scripts are routines to back up journal entries.  A backup hook is runs after an open hook and once the user closes the editor. The default behavior is to do nothing.

Hooks directory structure

```
<config root>/hooks/
             |----- open.d/		# stores editor specific hooks
             |----- open		# default open hook
             |----- backup.d/	# stores backup tool specific hooks
             |----- backup		# default backup hook
```

Journalscript runs only 1 open hook, and it searches for it in these locations in order:\ 

1. A hook specific to the configured editor. Any file under `<configuration/dir>/hooks/open.d/`. These hooks name must match the name of the editor. For example, the hook `<configuration/dir>/hooks/open.d/vim` is executed when the editor is `vim`, or `/usr/bin/vim`.\  
2. The default hook `<configuration/dir>/hooks/open`. This hook executes when no editor specific hooks is found.

Journalscript runs only 1 backup hook, and it searches for it in these locations in order:\ 

1. A hook specific to the configured editor. Any file under `<configuration/dir>/hooks/backup.d/`\ 
2. The default hook `<configuration/dir>/hooks/backup`

All journalscript's environment variables are available to hooks (see ENVIRONMENT). Additionally the following are also available to hooks:

JOURNALSCRIPT_JOURNAL_NAME\ 

: The name of the journal. For example: life, my-journal, workout-logs, etc.

JOURNALSCRIPT_JOURNAL_DIRECTORY\ 

: The parent directory to the journal directory.  For example, for the journal `/path/to/parent/directory/my-journal` the parent directory would be `/path/to/parent/directory/`

JOURNALSCRIPT_JOURNAL_ENTRY\ 

: The full path to the file corresponding to the day's entry.  The file to edit.

JOURNALSCRIPT_JOURNAL_ENTRY_FILE_NAME\ 

: The name of the file to edit.  It excludes the path to the file.

JOURNALSCRIPT_IS_NEW_JOURNAL_ENTRY\ 

: 1 if the file is new. 0 otherwise.

## Templates

Journalscript support templates for journal entries.  Templates are written into new entires, and they templates can be specific to a journal, apply to all journals (default), or they can be disabled.

Journal specific templates are to be stored in `$JOURNALSCRIPT_TEMPLATE_DIR/templates/tempate.d/`, and their name must match the journal name. For example, the template `$JOURNALSCRIPT_TEMPLATE_DIR/templates.d/banana` is picked up when the journal name is `banana`.

The default template is `$JOURNALSCRIPT_TEMPLATE_DIR/templates/tempalte`. It is optional, and it is picked up when it exists, and when no journal-specific template exists.

When no template exists, then journalscript writes the date into the first line of the journal entry.  This behavior can be disabled by having a blank default template.  

# EXAMPLES

journal\ 

: Writes to default journal



journal write\ 

: Writes to default journal



journal write my-journal\ 

: Writes to the journal named my-journal



journal configure\ 

: Runs configure show



journal configure show\ 

: Displays journalscript's configuration



journal configure init\ 

: Launches wizzard that assist users to creating a configuration
