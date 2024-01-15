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

It allows users to manage multiple journals, and it organizes them in directories. Each directory corresponds to a journal. Journal entries are stored in journal directories, and each entry is name as the current date (i.e. `2023-02-14.txt`).

Journalscript is highly configurable. However it requires no configuration upfront; its default behavior is sufficient and functional.

# OPTIONS

`-v`, `--version`\

: Prints version information and quits.

`--help`\

: Prints usage statement and quits.

# COMMANDS

## write [journal]

Writes a new entry to the journal. If no journal is provided, it writes to the default journal. Journals are stored as directories and each journal entry is a file in the journal directory. Each journal entry corresponds to a day, and their name is formated: YYYY-mm-dd.

The command creates new files if they don't exists, and it copies a template into them if template is configured. Then it launches the configured editor to open the new journal entry (or an existing one). Once the user closes the editor, journalscript invokes a backup hook if any exists.

## configure [show|init]

Assists with the configuration of journalscript. When configure is invoked with no arguments it defaults to show.

**show**\

Displays the configuration parameters (also referred as environment variables) along with its assigned values, and quits.

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

Journalscript behavior is customizable with via environment variables (see ENVIRONMENT). Additionally, journalscript supports loading variables from a file named `journalscript.env`. So user can either modify the environment or write a `journalscript.env` in order to customize journalscript. Journalscript looks for `journalscript.env` in two locations: first in `~/.config/journalscript/`, then in `~/.journalscript/`, and it only loads variables declared in the file that are not in the environment. That is, variables in the environment are not overridden.

Note: journalscript is not limited to loading journalscript-specific variables declared in file; any variable in journalscript.env will be declared. This makes journalscript.env a suitable place to declare additional variables used by hooks.

## Hooks

Hooks are bash scripts that Journalscript runs in order to sync and backup journal entries, and they allow users to customize these two actions. There are two types of hooks: sync and backup.

Sync hook scripts, as the name suggests, synchronizes journal entries with an externally backedup version of the journal. It is invoked before editing a journal.

Backup hook scripts are routines to back up journal entries. A backup hook is runs after an open hook and once the user closes the editor. The default behavior is to do nothing.

Hooks directory structure

```
<config root>/hooks/
             |----- sync.d/		# stores editor specific hooks
             |----- sync		# default sync hook
             |----- backup.d/	# stores backup tool specific hooks
             |----- backup		# default backup hook
```

Journalscript runs only 1 sync hook, and it searches for it in these locations in order:\

1. A hook specified by JOURNALSCRIPT_SYNC_BACKUP env var.\
2. The default hook `<configuration/dir>/hooks/backup`

Journalscript runs only 1 backup hook, and it searches for it in these locations in order:\

1. A hook specified by JOURNALSCRIPT_SYNC_BACKUP env var.\
2. The default hook `<configuration/dir>/hooks/backup`
