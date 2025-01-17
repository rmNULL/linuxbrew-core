class Abcmidi < Formula
  desc "Converts abc music notation files to MIDI files"
  homepage "https://ifdo.ca/~seymour/runabc/top.html"
  url "https://ifdo.ca/~seymour/runabc/abcMIDI-2020.06.22.zip"
  sha256 "972a3f2a265b9ec5a6661541587b39c2940cb87e12afd95dff5c9525e195ec8d"

  bottle do
    cellar :any_skip_relocation
    sha256 "619e0bd1606f918a6edb0c3745347a43e8670e0b1dec89f856697c236b0fc03b" => :catalina
    sha256 "401d729b3520d5bd6ec685189282633c1f3f11b6417b6dd8c94be627f1742f7c" => :mojave
    sha256 "cc9f5d24cf46f57f17a7f0cf0c05c857b60394905d75f76d10fc2e597c1d375b" => :high_sierra
    sha256 "9ea82aaead0a04cef4bd9a5a1c848cbb71ff9048fde912e42ff6f575d75b5ea1" => :x86_64_linux
  end

  def install
    # configure creates a "Makefile" file. A "makefile" file already exist in
    # the tarball. On case-sensitive file-systems, the "makefile" file won't
    # be overridden and will be chosen over the "Makefile" file.
    rm_f "makefile"

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    (testpath/"balk.abc").write <<~EOS
      X: 1
      T: Abdala
      F: https://www.youtube.com/watch?v=YMf8yXaQDiQ
      L: 1/8
      M: 2/4
      K:Cm
      Q:1/4=180
      %%MIDI bassprog 32 % 32 Acoustic Bass
      %%MIDI program 23 % 23 Tango Accordian
      %%MIDI bassvol 69
      %%MIDI gchord fzfz
      |:"G"FDEC|D2C=B,|C2=B,2 |C2D2   |\
        FDEC   |D2C=B,|C2=B,2 |A,2G,2 :|
      |:=B,CDE |D2C=B,|C2=B,2 |C2D2   |\
        =B,CDE |D2C=B,|C2=B,2 |A,2G,2 :|
      |:C2=B,2 |A,2G,2| C2=B,2|A,2G,2 :|
    EOS

    system "#{bin}/abc2midi", (testpath/"balk.abc")
  end
end
