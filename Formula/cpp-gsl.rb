class CppGsl < Formula
  desc "Microsoft's C++ Guidelines Support Library"
  homepage "https://github.com/Microsoft/GSL"
  url "https://github.com/Microsoft/GSL/archive/v3.1.0.tar.gz"
  sha256 "d3234d7f94cea4389e3ca70619b82e8fb4c2f33bb3a070799f1e18eef500a083"
  head "https://github.com/Microsoft/GSL.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "ba5b32881db75527872525bcde6bef641bdb6c89dff511ccf5105229f1ba1e7c" => :catalina
    sha256 "262709d81631cc7aa7477b03bd1904320da93b12cecf4aded01e3cc59917287f" => :mojave
    sha256 "262709d81631cc7aa7477b03bd1904320da93b12cecf4aded01e3cc59917287f" => :high_sierra
    sha256 "97f327299cd75544b8cd99c97a7d574e00d939e3e001cdec0b9045df30731977" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", "-DGSL_TEST=false", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <gsl/gsl>
      int main() {
        gsl::span<int> z;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "test", "-std=c++14"
    system "./test"
  end
end
