
<h1 align="center">Journalscript</h1>
<p align="center">A handy cli tool to write journals</p>

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 
[![CI](https://github.com/al3jandr0/journalscript/actions/workflows/ci.yml/badge.svg)](https://github.com/al3jandr0/journalscript/actions/workflows/ci.yml)

</div>

## Why journalscript

Journalscript allows you to journal without leaving your terminal.  It removes the friction that exists when writing a (digital) journal which is to launch a separate journaling app.

Journalscript is ideal for those who 1) work primarily in the terminal and 2) whish to journal more or alrady journal routinely. 

## Features
- Use within the terminal
- Ready to use out of the box
- Support writing multiple journals
- It is Highly configurable
- Support templates for journal entries

## Getting started

### Installation

#### Linux: debian, debian-based, ubuntu
1. Download the debian pacakge (i.e. `journalscript_0.2.0_all.deb`) from the [release page](https://github.com/al3jandr0/journalscript/releases)
2. Then run `sudo apt install journalscript_*_all.deb`
3. Verify the installation by running `journal -v`. It should print the version number. Like this `journalscript 0.2.0`

#### Other Linux distibutions - from source

For outher distros download the source.

1. Move journal.sh somewhere in your path such that it gets picked it up and make it executable, and (optionaly) remove the extension `.sh`
Example:
```install -T -m 755 ./journal.sh $HOME/.local/bin/journal```

2. Copy the manual `journalscript.1` to a location that it will be found by the `man` command
For Example:
```cp journalscript.1 /usr/share/man/man1/journalscript.1```

3. If you are running bash shell, copy the autocomplete script to an appropiate locaition
For example:
```cp src/autocomplete.sh /usr/share/bash-completion/completions/journal```
OR ```cp src/autocomplete.sh .local/share/bash-completion/completions/journal```


#### MacOS - Homebrew

You will need to make sure you have Homebrew installed on your system. The instructions to do that can be found [here](https://brew.sh/)

##### Option 1. Install the formula
1. Download the formula `journalscript.rb` from the [release page](https://github.com/al3jandr0/journalscript/releases)
2. Then run `brew instlal journalscript.rb`
3. Verify the installation by running `journal -v`. It should print the version number. Like this `journalscript 0.2.0`
4. Recomended. Install the bash autocomplete script (for bash terminal only)

#### Option 2. Install from [my tap](https://github.com/al3jandr0/homebrew-tap)

1. Install tap `brew install tap al3jandr0/homebrew-tap`
2. Then install the formula `brew install journalscript`
3. Verify the installation by running `journal -v`. It should print the version number. Like this `journalscript 0.2.0`

#### MacOS - from source

Follow the steps Linux - from sournce


### Using Journalscript
Comming soon!

## Configure
Comming soon!

## Examples:
Comming soon!
