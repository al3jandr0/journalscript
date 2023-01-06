# journalscript

A handy script to manage journals

## Getting started

Clone the repo, cd into its root, and run the installation scrip 


### Features to implemen
- [ ] Add support for .env in order to allow for directory-level configured journals
- [ ] Add support for method-agnostic post-save hooks in order to support automatic backup once a file is added or edited in order to de-couple backup mechanism
- [ ] Consider adding a pre-hool. At the moment Im pasing to the editor an order list of journal entries, but for vim I only pass the last two. some editors can open direcotries, some rather open files
- [ ] Nice to have: make the schipt POSIX complient - make it run on different terminal emulators bash, fish, etc.
- [ ] Package for arch, debian-like, fedora, and home-brew

### Tests
1. Command: 'config init'
1.1 Test journalscript config init
1.1.1 Test defaults
1.1.2 Test custom content but default location
1.1.3 Test default content but custom location
1.1.4 Test invalid location of data dir (no permissions) such that it command produces an error, and no config file is created
1.1.5 Test invalid location of template dir (no permissions) such that it command produces an error, and no config file is created
1.1.6 Test invalid location of config dir (no permissions) such that it command produces an error, and no config file is created

1.2 Command: 'config'|'config show'
1.2.1 Test config show with config located in $HOME
    write config gile in $HOME/
    run 'journal config'
    validate stdout

    Last two steps can be done with a unit test framework. However the first step 
    but the first mutates the file system
1.2.2 Test config show with config located in $XDG_CONFIG/journalscript
1.2.3 No config file displays default values
1.2.4 Test config shows override vars in the environment

2. Command: ''|'write'
2.1 Test journalscript write create 
2.1.1 Test command generates a file in the expected location 
2.1.2 Test command generates a file with the expected name format 
2.1.3 Test command generates a file in the expected location with the expected template (if any) 
2.2 Test journalscript write edit 
2.2.1 Test no new file is created in data directory
