###############################################################################
# Generates a Homebrew formula for a release                                  #
###############################################################################

TAR_BALL_URL=${1:?"Source tar ball url is required"}
SHA256=${2:?"Source tar ball sha256 is required"}
README=${3:"README.md"}
LICENSE=${4:"LICENSE"}

cat >"release/journalscript.rb" <<-EOF
	class Journalscrtip < Formula
	  desc "Interactive command-line journaling tool"
	  homepage "https://github.com/al3jandr0/journalscript"
	  url "${TAR_BALL_URL}"
	  sha256 "${SHA256}"
	  license "MIT"
	  # TODO: this is to run test only, you could run test if youd liek but you must make your tets
	  # environment independet.  That is to reset Env var --- Actually. to laucn test with emptu Env
	  #depends_on "bats" => [:test]
	  depends_on "bash"
	  depends_on "coreutils"
	 
	  def install
	    bin.install "src/journal.sh" => "journal"
	    prefix.install "${README}"
	    prefix.install "${LICENSE}"
	    # TODO: source doenst have manpage so Im ignoring for now
	    man.mkpath
	    man1.install "release/journalscrip.1" => "journalscript.1"
	  end

	  test do
	    assert_equal "journalscript 0.0.2", shell_output("#{bin}/journal -v").strip
	  end
	end
EOF
