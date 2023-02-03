# journalscript

A handy script to manage journals

## Getting started

Clone the repo, cd into its root, and run the installation scrip 


### Features to implement
- [x] Add support for .env in order to allow for directory-level configured journals
- [x] Add support for method-agnostic post-save hooks in order to support automatic backup once a file is added or edited in order to de-couple backup mechanism
- [x] Consider adding a pre-hook. At the moment I'm passing to the editor an order list of journal entries, but for vim I only pass the last two. Some editors can open directories, some rather open files
- [x] Test all commands
- [x] Print hook env var in configure show (update tests)
- [x] Rename JOURNALSCRIPT_DATA_DIR to JOURNALSCRIPT_JOURNAL_DIR
- [x] Set "strict" mode
- [x] Standarize throwing errors
- [x] Re-write error messages
- [x] refactor: make loading of lib and common setup run once per test suite
- [x] Add tags to test (1 tag per command)
- [x] Rename test files
- [x] anchor bats version
- [x] Set a timeout for bats tests

#### Checkpoint
- [ ] CICD run tests uppon merge or as merge check?
- [ ] Add license
- [ ] Write a readme:
- - Motivation
- - For devs: decisions / philosophy
- - installation guide
- - features highlight
- - version, and testing
- - dependencies
- - release page
- - quickguide
- [ ] Package
- - [ ] apt
- - [ ] pacman
- - [ ] dnf
- - [ ] homebrew
- - [ ] Windows?
- - Make isntallable from source. Add make ?
- [ ] Find out language for init_config
- [ ] Implement help - Find out language guide
- [ ] Proof read the entire program. Look for inconsistent language and typos
- [ ] Add a man page
- [ ] Add man page
- [ ] Add support for dynamic templates
- [ ] init_config: update user feedback


#Maybes
- [ ] Implement LS command
- [ ] Nice to have: make the script POSIX compliant - make it run on different terminal emulators bash, fish, etc.
- [ ] Nice to have: Pretify init_config (emojis)?

## Missing Tests cases
- 3. Command: help
- 3.1 Help adheres to usage / help format
- 3.2 Help <command> prints the command-specific usage / help
- 3.3 Help always exits with 0 code
- 3.4 Help prints only to stdout

## Invariants
- 1. Nothing else beside the output of the command is allowed to be printed to stout
- 2. No file in the FS is modified except for those in the DATA directory - could make stricter by permitting only 1 file (the most recent one) in DATA to be modified 

