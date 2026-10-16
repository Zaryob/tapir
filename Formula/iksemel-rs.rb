class IksemelRs < Formula
  desc "XML validation, benchmarking, and XMPP roster tools written in Rust"
  homepage "https://github.com/Zaryob/iksemel-rs"
  url "https://github.com/Zaryob/iksemel-rs/releases/download/v0.5.0/iksemel-0.5.0.crate"
  sha256 "093dfec7cbd7d390ee98627a15e08671fd60a9682be4f28d7b62eeae18e17ba5"
  license "LGPL-2.1-or-later"

  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "openssl@3"
  end

  def install
    system "cargo", "install", *std_cargo_args, "--bins"
  end

  test do
    (testpath/"document.xml").write "<root><entry>Tapir</entry><entry/></root>"
    output = shell_output("#{bin}/ikslint --stats --histogram document.xml")
    assert_match "Tags: 2 pairs, 1 single, 2 max depth.", output
    assert_match "<entry> 2 times.", output

    (testpath/"invalid.xml").write "<root><entry></root>"
    assert_match "Error:", shell_output("#{bin}/ikslint invalid.xml 2>&1", 1)
  end
end
