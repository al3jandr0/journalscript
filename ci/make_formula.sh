###############################################################################
# Generates a Homebrew formula for a release                                  #
###############################################################################

TAR_BALL_URL=${1:?"Source tar ball url is required"}
SHA256=${2:?"Source tar ball sha256 is required"}
VERSION=${3:-$VERSION}
VERSION=${VERSION/#v/}
MANUAL=${4:-"journalscript.1"}
README=${5:-"README.md"}
LICENSE=${6:-"LICENSE"}

cat >"journalscript.rb" <<-EOF
	class Journalscript < Formula
	  desc "Interactive command-line journaling tool"
	  homepage "https://github.com/al3jandr0/journalscript"
	  url "${TAR_BALL_URL}"
	  sha256 "${SHA256}"
	  license "MIT"
	  depends_on "bash"
	  depends_on "coreutils"

	  def install
	    bin.install "src/journal.sh" => "journal"
	    prefix.install "${README}"
	    prefix.install "${LICENSE}"
	    man.mkpath
	    man1.install "${MANUAL}" => "journalscript.1"
	  end

	  test do
	    assert_equal "journalscript ${VERSION}", shell_output(" #{bin}/journal -v").strip
	  end
	end
EOF
