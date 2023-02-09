---
title: journalscript
section: 1
date: FEBRUARY 2023
header: Journalscript Manual
---

# NAME
journalscript - an interactive command line journaling tool

# SYNOPSIS
journalscript

journalscript `COMMAND [ARG...]`

journalscript `[--help|-v|--verions]`

# DESCRIPTION

Journalscript is an interactive journaling tool for the command line.

It allows users to manage multiple journals, and it organizes them in directories.  Each directory corresponds to a journal.  Journal entries are stored in journal directories, and each entry is name as the current date (i.e. `2023-02-14.txt`)

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

**TEMPLATES**

Journalscript looks for templates in the following locations:

1. A template specific to the editor.  Any template file under `/templates/tempate.d/` with name matching the editor
2. The default template `/templates/template`

In case no other template is found, the fall back behavior is to write the the current date on the first line of the journal entry. 

## configure [show|init]

Assists with the configuration of journalscript.  When configure is invoked with no arguments it defaults to show.

**show**\ 

Displays the configuration parameters (also referred as environment variables) along with  its assigned values, and quits.

**<u>init</u>**\ 

Launches an interactive wizard that helps the user setting up a journalscript configuration

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

## Hooks

**HOOKS**

Journalscript leverages hooks to allow users to customize editing and backing up journal entries.  By default, journalscript opens a journal entry using the configured editor (JOURNALSCRIPT_EDITOR), and it takes no action to backup entries.  However, by configuring an **open hook**, users can customize both the choice of editor and the arguments passed to the editor, and by configuring a **backup hook**, users tell journalscript to run a backup routine upon exiting the editor. 

Hooks directory structure

```
<config root>/hooks/
             |----- open.d/		# stores editor specific hooks
             |----- open		# default open hook
             |----- backup.d/	# stores backup tool specific hooks
             |----- backup		# default backup hook
```

Journalscript looks for an open hook in this order:\ 

1. A hook specific to the configured editor. Any file under `/hooks/open.d/`\ 
2. The default hook `/hooks/open`

Journalscript looks for backup hook in this order:\ 

1. A hook specific to the configured editor. Any file under `/hooks/backup.d/`\ 
2. The default hook `/hooks/backup`

# EXAMPLES
