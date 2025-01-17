class Latexdiff < Formula
  desc "Compare and mark up LaTeX file differences"
  homepage "https://www.ctan.org/pkg/latexdiff"
  url "https://github.com/ftilmann/latexdiff/releases/download/1.3.1.1/latexdiff-1.3.1.1.tar.gz"
  sha256 "5e55ee205750ccbea8d69cf98791707e7a42ab88e92d3a1101f9de53643aa1d3"

  bottle do
    cellar :any_skip_relocation
    sha256 "8eb979b1b52125f102bbc56bbc4611d5b8075f003318307a2205485d95c789aa" => :catalina
    sha256 "8eb979b1b52125f102bbc56bbc4611d5b8075f003318307a2205485d95c789aa" => :mojave
    sha256 "8eb979b1b52125f102bbc56bbc4611d5b8075f003318307a2205485d95c789aa" => :high_sierra
    sha256 "d9cb7732a465de6fa6084717b20e21bcb708fbe55e46c847eabbc9613871fbae" => :x86_64_linux
  end

  # osx default perl cause compilation error
  depends_on "perl"

  def install
    bin.install %w[latexdiff-fast latexdiff-so latexdiff-vc latexrevise]
    man1.install %w[latexdiff-vc.1 latexdiff.1 latexrevise.1]
    doc.install Dir["doc/*"]
    pkgshare.install %w[contrib example]

    # Install latexdiff-so (with inlined Algorithm::Diff) as the
    # preferred version, more portable
    bin.install_symlink "latexdiff-so" => "latexdiff"
  end

  test do
    (testpath/"test1.tex").write <<~EOS
      \\documentclass{article}
      \\begin{document}
      Hello, world.
      \\end{document}
    EOS

    (testpath/"test2.tex").write <<~EOS
      \\documentclass{article}
      \\begin{document}
      Goodnight, moon.
      \\end{document}
    EOS

    expect = /^\\DIFdelbegin \s+
             \\DIFdel      \{ Hello,[ ]world \}
             \\DIFdelend   \s+
             \\DIFaddbegin \s+
             \\DIFadd      \{ Goodnight,[ ]moon \}
             \\DIFaddend   \s+
             \.$/x
    assert_match expect, shell_output("#{bin}/latexdiff test[12].tex")
  end
end
