class Iksemel < Formula
  desc "XML parser library with SAX and DOM interfaces"
  homepage "https://github.com/Zaryob/iksemel"
  url "https://github.com/Zaryob/iksemel/archive/refs/tags/1.6.2.tar.gz"
  sha256 "8055705c89df7fc0c64d7052188650dfdf3e049da8a7700f19240d8948ecb16c"
  license "LGPL-2.1-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build

  def install
    system "meson", "setup", "build", *std_meson_args,
           "-Dversion=#{version}",
           "-Dopenssl=disabled",
           "-Dgnutls=disabled",
           "-Dwith_tools=false",
           "-Dwith_python=false",
           "-Dtests=true"
    system "meson", "compile", "-C", "build"
    system "meson", "test", "-C", "build", "--print-errorlogs"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <iksemel.h>
      #include <stdio.h>
      #include <string.h>

      int main(void) {
        const char *xml = "<root id='42'><child>tapir &amp; XML</child></root>";
        int error = IKS_OK;
        iks *root = iks_tree(xml, strlen(xml), &error);
        if (!root || error != IKS_OK) return 1;

        const char *id = iks_find_attrib(root, "id");
        const char *text = iks_find_cdata(root, "child");
        int valid = strcmp(iks_name(root), "root") == 0 && id && text &&
                    strcmp(id, "42") == 0 && strcmp(text, "tapir & XML") == 0;
        iks_delete(root);
        if (!valid) return 2;
        puts("XML parsed successfully");
        return 0;
      }
    C

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-liksemel", "-o", "test"
    assert_equal "XML parsed successfully\n", shell_output("./test")
    assert_path_exists lib/"pkgconfig/iksemel-#{version}.pc"
  end
end
