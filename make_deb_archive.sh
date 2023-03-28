#!/usr/bin/env bash
###############################################################################
# Script to create a debian package of Journalscripti                         #
###############################################################################
#
# Targe script to package
SCRIPT="./src/journal.sh"
# Source name and version from the script itself
# > $SCRIPT -v 
# > <name> <version-number>
name_version=( $(bash $SCRIPT -v) )
PACKAGE_NAME="${name_version[0]}"
VERSION="${name_version[1]}"
ARCHITECTURE="all"
ARCHIVE="release/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}"
INSTALATION_DIR="/bin"

# Removes dir path of the script
file_name="${SCRIPT##*/}"
# Removes extension (.sh, .bash, etc.)
without_extension="${file_name%%.*}"
mkdir -p "${ARCHIVE}${INSTALATION_DIR}"
cp $SCRIPT "${ARCHIVE}${INSTALATION_DIR}/$without_extension"

# Debian directory is capitalize since this is not a srouce archive
mkdir -p "${ARCHIVE}/DEBIAN"

# Populate control file
cat > "${ARCHIVE}/DEBIAN/control" <<-EOF
Package: $PACKAGE_NAME
Version: $VERSION 
Architecture: $ARCHITECTURE
Section: utils
Depends: bash (>= 3.2), coreutils (>= 8)
Recommends: bash (>= 4.2)
Suggests: direnv
Priority: optional
Maintainer: Alejandro <nerdalej@gmail.com> 
Description: Interactive command line journaling tool.
 Jounslscript lets users write journals via its command line interface, and it
 is designed to reduce friction when journaling for those who work primirely in
 a terminal.
EOF

# Build archive
dpkg-deb --build --root-owner-group $ARCHIVE
