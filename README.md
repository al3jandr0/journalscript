# journalscript

A handy script to manage journals

## Getting started

Clone the repo, cd into its root, and run the installation scrip 


### Features to implement
- [ ] Add support for .env in order to allow for directory-level configured journals
- [ ] Add support for method-agnostic post-save hooks in order to support automatic backup once a file is added or edited in order to de-couple backup mechanism
- [ ] Consider adding a pre-hook. At the moment I'm passing to the editor an order list of journal entries, but for vim I only pass the last two. Some editors can open directories, some rather open files
- [ ] Nice to have: make the script POSIX compliant - make it run on different terminal emulators bash, fish, etc.
- [ ] Package for arch, debian-like, fedora, and home-brew
- [ ] Add man page
- [ ] Package
- - [ ] apt
- - [ ] pacman
- - [ ] dnf
- - [ ] homebrew
- - [ ] Windows?

## Tests - cases

1 Command: configure
1.1 Subcommand: show
1.1.1 Test No config file and no env overrides and no xdg directories displays default values
1.2.2 Test config file located in $HOME gets picked up
1.2.3 Test config file located in $XDG_CONFIG/journalscript get picked up
1.2.4 Test config file located in custom location gets picked up with appropiate env overrides
1.2.5 Test config shows existing env vars over those in configuration file

1. Command: configure
1.2 Subcommand: init
1.2.1 Test defaults
1.2.2 Test custom values and default location
1.2.3 Test default values and custom location
1.2.4 Test invalid location of data dir (no permissions) such that it command produces an error, and no config file is created
1.2.5 Test invalid location of template dir (no permissions) such that it command produces an error, and no config file is created
1.2.6 Test invalid location of configuration dir (no permissions) such that it command produces an error, and no config file is created

2. Command: write
2.1 Subcommand: write create 
2.1.1 Test command creates default journal if journal doesn't exist
2.1.2 Test command creates provided journal if journal doesn't exist
2.1.3 Test command creates a journal entry in the journal directory
2.1.4 Test command doesn't create a new file if target file exits 
2.1.5 Test command fails when journalscript doesn't have permissions to target directory
2.2 Sub-component: write with templates
2.2.1 Test fallback behavior when there is no templates
2.2.2 Test default template is picked up at data directory
2.2.3 Test default template is picked up at configure directory
2.2.4 Test custom template is picked up at data directory
2.2.5 Test custom template is picked up at configure 
2.3 Sub-component: write with hooks
2.3.1 Test fallback open hook behavior
2.3.2 Test default open hook
2.3.3 Test open hook has access to all of JOURNALSCRIPT vars
2.3.4 Test editor specific hook
2.3.5 Test backup hook is executed if it exists
2.3.6 Test backup hook is not executed when open hook fails

3. Command: help
3.1 Help adheres to usage / help format
3.2 Help <command> prints the command-specific usage / help
3.3 Help always exits with 0 code
3.4 Help prints only to stdout

## Invariants
1. Nothing else beside the output of the command is allowed to be printed to stout
2. No file in the FS is modified except for those in the DATA directory - could make stricter by permitting only 1 file (the most recent one) in DATA to be modified 
3. Env is inmutable. No var should be exported or unset
4. The updated or created file (if any) should adhere to the format <date>.<type>

### Terminal specific?
1. Always run as interactive?

