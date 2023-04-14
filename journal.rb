class Journal < Formula
  desc "Interactive command-line journaling tool"
  homepage "https://github.com/al3jandr0/journalscript"
  url "https://github.com/al3jandr0/journalscript/archive/refs/tags/v0.0.2.tar.gz"
  sha256 "4907821b0cb1f19ce053e0416a55eabe96271303d26b1600e866966c55c6d1df"
  license "MIT"
  # TODO: this is to run test only, you could run test if youd liek but you must make your tets
  # environment independet.  That is to reset Env var --- Actually. to laucn test with emptu Env
  #depends_on "bats" => [:test]
  depends_on "bash"
  depends_on "coreutils"

  def install
    bin.install "src/journal.sh" => "journal"
    prefix.install "README.md"
    prefix.install "LICENSE"
    # TODO: source doenst have manpage so Im ignoring for now
    #man.mkpath
    #man1.install "release/journalscrip.1" => "journalscript.1"
  end

  test do
    assert_equal "journalscript 0.0.2", shell_output("#{bin}/journal -v").strip
  end
end
