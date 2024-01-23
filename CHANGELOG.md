# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v.0.5.4 - 2024-01-22

### Fixed

- bugs in write command overriding exiting file
- errors in git add, commit, push sequence

### Added

- Messaging when a file is created
- Messaging when an entry is added
- Messaging when a file is backed up
- Messaging when the journal is synched

## v.0.5.3 - 2024-01-16

### Fixed

- Git hook bugs

## v.0.5.2 - 2024-01-16

### Changes

- Adds quiet flag to git commands

## v.0.5.1 - 2024-01-16

### Changes

- Archive to README. This is for homebrew formula installation.

## v.0.5.0 - 2024-01-15

### Added

- Embeds git sync and backup
- Displays config file location in configure show command
- Grouping of entires by day, month and year

### Changes

- Removes open hook support
- Removes templates support

## v.0.3.0 - 2023-05-04

### Added

- User feedback upon sync, backup, file created and/or edited
- Adds hooks directory structure to configure init

## v.0.2.3 - 2023-05-02

### Fixed

- Homebrew formula inconsistent sha

## v.0.2.2 - 2023-05-02

### Changes

- Removes README docs and ci files from release source archive

## v.0.2.1 - 2023-05-02

### Fixed

- Fixes missing reading last line of config file
- Adds missing expansion of ~ in JOURNALSCRIPT_EDITOR
- Adds missing JOURNALSCRIPT_SYNC_BACKUP from configure init

## v.0.2.0 - 2023-04-27

### Added

- Support of Backup hook
- Support of Sync hook

### Changed

- Exit fail upon first error

## v.0.1.0 - 2023-04-26

### Added

- Dynamic templates

## v.0.0.2 - 2023-04-25

### Added

- First pre-release.
