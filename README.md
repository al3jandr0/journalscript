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

### Tests - cases
x1. Command: 'config init'
x1.1 Test journalscript config init
x1.1.1 Test defaults
x1.1.2 Test custom content but default location
x1.1.3 Test default content but custom location
x1.1.4 Test invalid location of data dir (no permissions) such that it command produces an error, and no config file is created
x1.1.5 Test invalid location of template dir (no permissions) such that it command produces an error, and no config file is created
x1.1.6 Test invalid location of config dir (no permissions) such that it command produces an error, and no config file is created

1 Command: configure
1.1 Subcommand: show
1.1.1 Test No config file and no env overrides and no xdg directories displays default values
1.2.2 Test config file located in $HOME gets picked up
1.2.3 Test config file located in $XDG_CONFIG/journalscript get picked up
1.2.4 Test config file located in custom location gets picked up with appropiate env overrides
1.2.5 Test config shows system override vars in the environment
1.2.6 Test config shows JOURNALSCRIPT specific override vars in the environment

2. Command: ''|'write'
2.1 Test journalscript write create 
2.1.1 Test command generates a file in the expected location 
2.1.2 Test command generates a file with the expected name format 
2.1.3 Test command generates a file in the expected location with the expected template (if any) 
2.2 Test journalscript write edit 
2.2.1 Test no new file is created in data directory

3. Command: help
3.1 Help adheres to usage / help format
3.2 Help <command> prints the command-specific usage / help
3.3 Help always exists with 0 code
3.4 Help prints only to stdout - undecided whether warnings should be allowed?

## Invariants
1. Nothing else beside the output of the command is allowed to be printed to stout
2. No file in the FS is modified except for those in the DATA directory - could make stricter by permitting only 1 file (the most recent one) in DATA to be modified 
3. Env is inmutable. No var should be exported or unset
4. The updated or created file (if any) should adhere to the format <date>.<type>

### Terminal specific?
1. Always run as interactive?

