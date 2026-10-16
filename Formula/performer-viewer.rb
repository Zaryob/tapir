class PerformerViewer < Formula
  desc "Offline browser viewer for Performer performance bundles"
  homepage "https://github.com/Zaryob/Performer"
  url "https://github.com/Zaryob/Performer/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "981f7a552bac8afb29e2e1145a0bf17426699f8746b2c79f621b2f68c730497c"
  license "Apache-2.0"

  on_linux do
    depends_on "xdg-utils"
  end

  def install
    pkgshare.install "viewer/dist/index.html"
    opener = OS.mac? ? "/usr/bin/open" : formula_opt_bin("xdg-utils")/"xdg-open"

    (bin/"performer-viewer").write <<~SH
      #!/bin/sh
      if [ "$#" -gt 1 ]; then
        echo "Usage: performer-viewer [--help|--version|--print-path]" >&2
        exit 1
      fi

      case "${1-}" in
        -h|--help)
          echo "Usage: performer-viewer [--help|--version|--print-path]"
          echo "Open the offline viewer in your default browser, then choose a Performer .tgz bundle."
          echo "--print-path prints the installed HTML path without opening a browser."
          ;;
        --version)
          echo "performer-viewer #{version}"
          ;;
        --print-path)
          echo "#{pkgshare}/index.html"
          ;;
        "")
          exec "#{opener}" "#{pkgshare}/index.html"
          ;;
        *)
          echo "Usage: performer-viewer [--help|--version|--print-path]" >&2
          exit 1
          ;;
      esac
    SH
    (bin/"performer-viewer").chmod 0755
  end

  def caveats
    <<~EOS
      Run performer-viewer to open the offline viewer, then select or drop a
      Performer .tgz bundle in the browser. No local server is needed.
      The Linux-only performance collector is distributed separately.
    EOS
  end

  test do
    assert_match "Usage: performer-viewer", shell_output("#{bin}/performer-viewer --help")
    assert_equal "performer-viewer #{version}\n", shell_output("#{bin}/performer-viewer --version")
    assert_equal "#{pkgshare}/index.html\n", shell_output("#{bin}/performer-viewer --print-path")
    assert_match "Usage: performer-viewer", shell_output("#{bin}/performer-viewer --invalid 2>&1", 1)

    html = (pkgshare/"index.html").read
    assert_match "<title>Performer</title>", html
    assert_match "<script", html
    refute_match(/<script[^>]+\bsrc=/i, html)
    refute_match(/<link[^>]+\brel=["']stylesheet["']/i, html)
  end
end
