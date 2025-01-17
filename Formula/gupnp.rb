class Gupnp < Formula
  include Language::Python::Shebang

  desc "Framework for creating UPnP devices and control points"
  homepage "https://wiki.gnome.org/Projects/GUPnP"
  url "https://download.gnome.org/sources/gupnp/1.2/gupnp-1.2.2.tar.xz"
  sha256 "9a80bd953e5c8772ad26b72f8da01cbe7241a113edd6084903f413ce751c9989"
  revision 1

  bottle do
    sha256 "0a7248c3b761e36ec36188d4b730c69cfd9c7fb5ea247e994bbce44dd8bf6366" => :catalina
    sha256 "efc4a54b6df3d4794c0a3e7ea6080839a5a29048af02201161ae7447f72c6a02" => :mojave
    sha256 "01d9c2e45bbcd2c0c2fb1a1cc630020a87f95aee47226cff9859b561a8aabb57" => :high_sierra
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gssdp"
  depends_on "libsoup"
  depends_on "python@3.8"

  def install
    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja"
      system "ninja", "install"
      bin.find { |f| rewrite_shebang detected_python_shebang, f }
    end
  end

  test do
    system bin/"gupnp-binding-tool-1.2", "--help"
    (testpath/"test.c").write <<~EOS
      #include <libgupnp/gupnp-control-point.h>

      static GMainLoop *main_loop;

      int main (int argc, char **argv)
      {
        GUPnPContext *context;
        GUPnPControlPoint *cp;

        context = gupnp_context_new (NULL, 0, NULL);
        cp = gupnp_control_point_new
          (context, "urn:schemas-upnp-org:service:WANIPConnection:1");

        main_loop = g_main_loop_new (NULL, FALSE);
        g_main_loop_unref (main_loop);
        g_object_unref (cp);
        g_object_unref (context);

        return 0;
      }
    EOS
    linker_flags = %W[
      -L#{lib}
      -lgupnp-1.2
      -lglib-2.0
      -lgobject-2.0
    ]
    system ENV.cc, "-I#{include}/gupnp-1.2", "-L#{lib}", "-lgupnp-1.2",
           "-I#{Formula["gssdp"].opt_include}/gssdp-1.2",
           "-L#{Formula["gssdp"].opt_lib}", "-lgssdp-1.2",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           "-L#{Formula["glib"].opt_lib}",
           "-lglib-2.0", "-lgobject-2.0",
           "-I#{Formula["libsoup"].opt_include}/libsoup-2.4",
           "-I" + (OS.mac? ? "#{MacOS.sdk_path}/usr/include/libxml2" : Formula["libxml2"].include/"libxml2"),
           testpath/"test.c", *(linker_flags unless OS.mac?), "-o", testpath/"test"
    system "./test"
  end
end
