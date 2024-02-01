<h1 align="center">Journalscript</h1>
<p align="center">Journal from the terminal</p>

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://github.com/al3jandr0/journalscript/actions/workflows/ci.yml/badge.svg)](https://github.com/al3jandr0/journalscript/actions/workflows/ci.yml)
[![Homebrew](https://github.com/al3jandr0/journalscript/actions/workflows/publish_homebrew_tap.yml/badge.svg?event=release)](https://github.com/al3jandr0/journalscript/actions/workflows/publish_homebrew_tap.yml)

</div>

Journalscript is a cli that allows you to write journals from the terminal.  It aims to reduce friction when writing a journals.


Just type `journal`, `Enter` and begin journaling.

## 📗 Install

### Linux: debian, debian-based, ubuntu

1. Download the the latest deb pacakge from the [release page](https://github.com/al3jandr0/journalscript/releases)
2. Verify the installation by running
   ```shell
   journal -v
   ```
   It should print the version number. Like this `journalscript 0.2.0`

 Other Linux distributions - Install from source

For other distros, download the source or clone the repo.

1. Move journal.sh somewhere to a directory included in your PATH, and (optionally) remove the `.sh.` Instal. For example:
   ```shell
   install -T -m 755 ./journal.sh $HOME/.local/bin/journal
   ```
2. Copy `journalscript.1` to a location where it will be found by the `man` command. For example:
   ```shell
   cp journalscript.1 /usr/share/man/man1/journalscript.1
   ```
3. If you are running a bash shell, copy the autocomplete script to an appropriate location. For example:
   ```shell
   cp src/autocomplete.sh /usr/share/bash-completion/completions/journal
   ```
   Or
   ```shell
   cp src/autocomplete.sh .local/share/bash-completion/completions/journal
   ```

### MacOS - Homebrew

Requires homebrew to be installed.  You can find instructions [here](https://brew.sh/) 

### Option 1. Install the formula

1. Download the formula `journalscript.rb` from the [release page](https://github.com/al3jandr0/journalscript/releases)
2. Then run
   ```shell
   brew install journalscript.rb
   ```
3. Verify the installation by running
   ```shell
   journal -v
   ```
   It should print the version number. Like this `journalscript 0.2.0`
4. If you are running bash shell, follow the steps to [enable completion for Homebrew](https://docs.brew.sh/Shell-Completion). Then, copy the autocomplete script to an appropriate location. For example:
   ```shell
   cp src/autocomplete.sh "${HOMEBREW_PREFIX}/etc/bash_completion.d/journal"
   ```

### Option 2. Use [my tap](https://github.com/al3jandr0/homebrew-tap)

1. Install tap
   ```shell
   brew tap al3jandr0/homebrew-tap
   ```
2. Then install the formula
   ```shell
   brew install journalscript
   ```
3. Verify the installation by running
   ```shell
   journal -v
   ```
   It should print the version number. Like this `journalscript 0.2.0`

### MacOS - from source

Follow the steps to [install from sournce](#other-linux-distibutions---install-from-source)

## 📗 Journal

Type `journal`, `Enter`, and begin journaling.  It creates a new journal and journal entry to the _life_ (default) journal (which can be customized)
![](./docs/resources/journaling.gif)

You can choose to write to a specific journal.
![](./docs/resources/journal_write_custom.gif)

Run `journal --help` for more information or read the manual `man journalscript`

## 📗 Customize

You can drop a `journalscript.env` configuration file into any of these locations
1. `$HOME/.config/journalscript/journalscript.env`
2. `$HOME/.journalscript/journalscript.env`

The command `journalscript configure init` assists you in setting up a new configuration. The command `configure show` (aliased just as `configure`) displays the resolved configuration.
![](./docs/resources/configure_init.gif)

In addition to customizing the configuration file `journalscript.env`, you can load variables into your environment to override the configuration of journalscript
![](./docs/resources/override_env_var.gif)

You can combine this feature with tools such as [direnv](https://direnv.net/) to have directory-level specific journalscript configurations.

Supported configurations
| Name | Value | Default | Description |
| --- | --- | --- | --- |
|JOURNALSCRIPT_EDITOR| vi,vim,nvim,emacs,code,etc.|`$EDITOR`| Command to launch an editor installed in your system |
|JOURNALSCRIPT_JOURNAL_DIR| path/to/directory | `$HOME/Documents/journals/` | Directory where journals are stored |
|JOURNALSCRIPT_GROUP_BY="YEAR" | DAY,MONTH,YEAR| YEAR | Specifies grouping of journal entries. One file per day, month, or year |
|JOURNALSCRIPT_DEFAULT_JOURNAL| name of the default journal | Any valid directory name | life | The default journal is selected when you type journal |
|JOURNALSCRIPT_SYNC_BACKUP| name of _hook_ plugin | | Hook to invoke to synchronize and backup your journals.  `git` is built into journalscrip. Others need to be "dropped" into the config directory  |


<!-- Add a table to the configure section covering all of the options 
## Organize

Journalscript creates an entry per day. However, these can be stored in a separate file per day, month, or year. You can select how you want to group your journal entries with the variable
`JOURNALSCRIP_GROUP_BY`. 

- Set `JOURNALSCRIP_GROUP_BY` to YEAR, to group entries by year; meaning only one file will be created per year and all daily entries for that year will be stored in that file.
- Set to MONTH, and only one file will be created per month and all a given month's entries will be stored in its corresponding file.
- Lastly, set to DAY and a new file will be created per day containing only that day's entry.


### Customizing the editor

Journalscript tries to use the editor the `EDITOR` variable set in your environment. If it is absent, then it defaults to `vim`. However you can configure journalscript to use any editor of choice with the `JOURNALSCRIPT_EDITOR`. For example edit `journalscript.env` and replace the default `JOURNALSCRIPT_EDITOR="vim"` with `JOURNALSCRIPT_EDITOR="emacs"`, `JOURNALSCRIPT_EDITOR="nvim"`, `JOURNALSCRIPT_EDITOR="code"`, etc.


The `JOURNALSCRIPT_EDITOR` settign supports flags. For example: `JOURNALSCRIPT_EDITOR="code -n $JOURNALSCRIPT_JOURNAL_DIRECTORY"` This command opens the directory that hosts all entires for the journal in a new window instead of opening today's entry only.


## Advanced options: Backing up and synching journals

Journalscript stores journals in the local file system (technically your editor of choice does the saving). However, it allows you to integrate with the backup mechanisms of your choosing. And it does so via hooks:

- _Sync_. Executes before any changes are done to the journal. It makes your local journal to be up tp date with the backup version. A la `git pull`
- _Backup_. Executes after quitting the editor. It summarizes (backups) the updates to the journals. Either it edits  an existing entry or a new entry. a la `git push`

Many cloud storage services (like DropBox, Google Drive, or OneDrive) do not need the kind of interaction that _Sync_ of _Backup_ allows for. For that kind of system, simply saving the journal files to designated directories is sufficient, and they take care of synchronization and cloud storage automatically. But other systems like git require more interaction. That's where sync and backup come in handy.
-->
<!---
For example -  Setting up a github repository to store your journals
- Todo: add verbose mode to configure show --verbose
- Todo: README: add instructions to create a new repo in the journals directory
- Todo: decide whether to continue to support open hook.  Seems redundant with EDITOR variable
    Decision: to remove the open hook once cadence is implemented
- Todo: simplify default behavior of backup and sync
  - Todo: embed git backup and sync scripts
- todo: Add Gif to demonstrate workflow
--->
