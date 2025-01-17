class Gh < Formula
  desc "GitHub command-line tool"
  homepage "https://github.com/cli/cli"
  url "https://github.com/cli/cli/archive/v0.10.0.tar.gz"
  sha256 "5d7474a89cd0d284387f1b58dc8b1771ebae8fc83cfa2410b354435b295c07df"

  bottle do
    cellar :any_skip_relocation
    sha256 "79b94d98c22ad3d8fc6130fc561a628c76a2d422d290d99baa9c8664daf16b57" => :catalina
    sha256 "479de4c4a07a78b2aebe4ae47c70c94058fee6bcf830323af1b65f23ceae0a1e" => :mojave
    sha256 "5819ffd8abedc81fdacb3d066a816cee17478904c664317a9a28691e0f3fcb16" => :high_sierra
    sha256 "e46bffae9626ad4f026278130c6410fd97d2ae84ce7375fd5d2c683a0f8376fe" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -X github.com/cli/cli/command.Version=#{version}
      -X github.com/cli/cli/command.BuildDate=#{Date.today}
      -s -w
    ]
    system "make", "bin/gh", "manpages", "LDFLAGS=#{ldflags.join(" ")}"
    bin.install "bin/gh"
    man1.install Dir["share/man/man1/gh*.1"]
    (bash_completion/"gh").write `#{bin}/gh completion -s bash`
    (fish_completion/"gh.fish").write `#{bin}/gh completion -s fish`
    (zsh_completion/"_gh").write `#{bin}/gh completion -s zsh`
  end

  test do
    assert_match "gh version #{version}", shell_output("#{bin}/gh --version")
    assert_match "Work with GitHub issues", shell_output("#{bin}/gh issue 2>&1")
    assert_match "Work with GitHub pull requests", shell_output("#{bin}/gh pr 2>&1")
  end
end
