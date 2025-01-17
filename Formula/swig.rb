class Swig < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz"
  sha256 "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"

  bottle do
    sha256 "530e80b7e7dcd28469b52fc3b668683a97b72642ebf2b6d4e6708d14f05e7286" => :catalina
    sha256 "50afb5930cb37af2e400f0369f6da15b1d4922c1f72f45d13e7e3f8bd9d6d27b" => :mojave
    sha256 "8bab440005b048ce454a3dd50ba608e1f85391edd73e9e40510269e923cad238" => :high_sierra
    sha256 "39c044d1f12dfc0fd0f6cb02eb4a7a3830f91f252c09fe82fe3c03379f3635d1" => :x86_64_linux
  end

  head do
    url "https://github.com/swig/swig.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pcre"

  uses_from_macos "ruby" => :test

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      int add(int x, int y)
      {
        return x + y;
      }
    EOS
    (testpath/"test.i").write <<~EOS
      %module test
      %inline %{
      extern int add(int x, int y);
      %}
    EOS
    (testpath/"run.rb").write <<~EOS
      require "./test"
      puts Test.add(1, 1)
    EOS
    system "#{bin}/swig", "-ruby", "test.i"
    if OS.mac?
      system ENV.cc, "-c", "test.c"
      system ENV.cc, "-c", "test_wrap.c",
             "-I#{MacOS.sdk_path}/System/Library/Frameworks/Ruby.framework/Headers/"
      system ENV.cc, "-bundle", "-undefined", "dynamic_lookup", "test.o", "test_wrap.o", "-o", "test.bundle"
      assert_equal "2", shell_output("/usr/bin/ruby run.rb").strip
    else
      include_dir1 = "#{Formula["ruby"].opt_include}/ruby-2.7.0"
      include_dir2 = "#{Formula["ruby"].opt_include}/ruby-2.7.0/x86_64-linux/"
      args = Utils.safe_popen_read(
        Formula["ruby"].opt_bin/"ruby", "-e", "'puts RbConfig::CONFIG[\"LIBRUBYARG\"]'"
      ).chomp
      system ENV.cc, "-c", "-fPIC", "test.c"
      system ENV.cc, "-c", "-fPIC", "test_wrap.c",
             "-I#{include_dir1}", "-I#{include_dir2}"
      system ENV.cc, "-shared", "test.o", "test_wrap.o", "-o", "test.so",
             *args.delete("'").split
      assert_equal "2", shell_output("ruby run.rb").strip
    end
  end
end
