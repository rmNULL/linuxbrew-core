class Sqliteodbc < Formula
  desc "SQLite ODBC driver"
  homepage "https://ch-werner.homepage.t-online.de/sqliteodbc/"
  url "https://ch-werner.homepage.t-online.de/sqliteodbc/sqliteodbc-0.9997.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/sqliteodbc-0.9997.tar.gz"
  sha256 "a50cc328a7def2b3389eebeee43c598322ed338506cbd13d8e9d1892db5e0cfe"

  bottle do
    cellar :any
    sha256 "c49e1d843386a98770b7862f8cff4c6e8329c1c164ddf5fbe775fa7ae51a8cdf" => :catalina
    sha256 "ced11b3b38c9c2cc8b6f4271a07f77015d2a412f2c8cdcae77b6d93139e0b31d" => :mojave
    sha256 "eb9cc3938701ae4b37413b9ed457ee64e0d5ee0534451fc3f3c755b5bae8bace" => :high_sierra
    sha256 "1974308e036e51466381e13bbe6342a289a110746a53ca1a766fa920b4aac1b4" => :x86_64_linux
  end

  depends_on "sqlite"
  depends_on "unixodbc"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    ENV["SDKROOT"] = MacOS.sdk_path if MacOS.version == :sierra

    unless OS.mac?
      # sqliteodbc ships its own version of libtool, which breaks superenv.
      # Therefore, we set the following enviroment to help it find superenv.
      ENV["CC"] = which("cc")
      ENV["CXX"] = which("cxx")
    end
    lib.mkdir
    args = ["--prefix=#{prefix}", "--with-odbc=#{Formula["unixodbc"].opt_prefix}"]
    unless OS.mac?
      args += ["--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
               "--with-libxml2=#{Formula["libxml2"].opt_prefix}"]
    end

    if OS.mac?
      ENV["SDKROOT"] = MacOS.sdk_path if MacOS.version == :sierra
    end
    system "./configure", *args

    system "make"
    system "make", "install"
    lib.install_symlink "#{lib}/libsqlite3odbc.dylib" => "libsqlite3odbc.so" if OS.mac?
  end

  test do
    output = shell_output("#{Formula["unixodbc"].opt_bin}/dltest #{lib}/libsqlite3odbc.so")
    assert_equal "SUCCESS: Loaded #{lib}/libsqlite3odbc.so\n", output
  end
end
