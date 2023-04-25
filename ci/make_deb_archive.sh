#!/usr/bin/env bash
#
# Script to create a debian package of Journalscript                          #
#
set -e

###############################################################################
# Inputs                                                                      #
###############################################################################
# Targe script to package
CHANGELOG=${1:-"CHANGELOG.md"}
MANUAL_PAGE=${2:-"journalscript.1"}
COPYRIGHT=${3:-"LICENSE"}
SCRIPT=${4:-"src/journal.sh"}

###############################################################################
# Outputs                                                                     #
###############################################################################
# archive: release/<package-name>_<version>_<architecture>.deb

# Source name and version from the script itself
# > $SCRIPT -v
# > <name> <version-number>
read -ra name_version < <(bash "$SCRIPT" -v)
PACKAGE_NAME="${name_version[0]}"
VERSION="${name_version[1]}"
ARCHITECTURE="all"
ARCHIVE="release/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}"
INSTALATION_DIR="/bin"
DOCUMENTS_DIR="${ARCHIVE}/usr/share/doc/${PACKAGE_NAME}"

###############################################################################
# Copy source                                                                 #
###############################################################################
# Removes directory path of the script
file_name="${SCRIPT##*/}"
# Removes extension (.sh, .bash, etc.)
executable_without_extension="${file_name%%.*}"
mkdir -p "${ARCHIVE}${INSTALATION_DIR}"
cp "$SCRIPT" "${ARCHIVE}${INSTALATION_DIR}/$executable_without_extension"

###############################################################################
# Write changelog                                                             #
###############################################################################
mkdir -p "$DOCUMENTS_DIR"
bash ci/make_gnu_changelog.sh "$CHANGELOG" "$SCRIPT" |
    gzip -9 -cn >"$DOCUMENTS_DIR/changelog.gz"

###############################################################################
# Write manual page                                                           #
###############################################################################
MAN_DIR="${ARCHIVE}/usr/share/man/man1/"
mkdir -p "$MAN_DIR"
gzip -9 -cn "$MANUAL_PAGE" >"${MAN_DIR}${executable_without_extension}.1.gz"

###############################################################################
# Write copyright file                                                         #
###############################################################################
mkdir -p "$DOCUMENTS_DIR"
cp "$COPYRIGHT" "$DOCUMENTS_DIR/copyright"

###############################################################################
# Write control file                                                          #
###############################################################################

# Debian directory is capitalized since this is not a srouce archive
mkdir -p "${ARCHIVE}/DEBIAN"

# Populate control file
cat >"${ARCHIVE}/DEBIAN/control" <<-EOF
	Package: $PACKAGE_NAME
	Version: $VERSION
	Architecture: $ARCHITECTURE
	Section: utils
	Depends: bash (>= 3.2), coreutils (>= 8)
	Recommends: bash (>= 4.2)
	Suggests: direnv
	Priority: optional
	Maintainer: Alejandro <contact.al3j@gmail.com> 
	Description: Interactive command line journaling tool.
	 Jounslscript lets users write journals via its command line interface, and it
	 is designed to reduce friction when journaling for those who work primirely in
	 a terminal.
EOF

# Build archive
dpkg-deb --build --root-owner-group "$ARCHIVE"
