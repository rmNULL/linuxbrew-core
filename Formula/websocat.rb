class Websocat < Formula
  desc "Command-line client for WebSockets"
  homepage "https://github.com/vi/websocat"
  url "https://github.com/vi/websocat/archive/v1.5.0.tar.gz"
  sha256 "3ffdb25e937095d95b564eafd805cb7ca141570f95c1296b6dd336d4d016445f"
  revision 1 unless OS.mac?

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "fd1061d818e394d5678661b0c8559bcd61d586e0a0498e1a58a6a72d271adc33" => :catalina
    sha256 "011b0892734d27b6a978b372fd342bbecccd75e9f29d8d2cf8e9944b30d2ff50" => :mojave
    sha256 "b59d7c3fc70e1e643986c0414b7d8cc4897f611cb15affa21092f43d69ccbab2" => :high_sierra
    sha256 "bbda75d2a4793faf5ae42bba2326bb74964c1f7e729fb1acb2946959eb488ecb" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@1.1"
  end

  def install
    system "cargo", "install", "--locked", "--root", prefix,
                               "--path", ".",
                               "--features", "ssl"
  end

  test do
    system "#{bin}/websocat", "-t", "literal:qwe", "assert:qwe"
  end
end
