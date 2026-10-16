class DockerTui < Formula
  desc "Keyboard-driven terminal interface for Docker"
  homepage "https://github.com/Zaryob/docker-tui"
  url "https://github.com/Zaryob/docker-tui/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "dd0ad706775c0bc2fef8b77dbf9170d75ff25e824758cce9a465f6b3fff7cfc4"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  def caveats
    <<~EOS
      A running Docker daemon is required, such as Docker Desktop or Colima.
      Full-screen shells, image builds, and build history also require the
      Docker CLI with the buildx plugin.
    EOS
  end

  test do
    assert_equal "docker-tui #{version}\n", shell_output("#{bin}/docker-tui -version")
    output = shell_output("#{bin}/docker-tui -host unix://#{testpath}/missing.sock 2>&1", 1)
    assert_match "cannot reach docker daemon", output
    assert_match "#{testpath}/missing.sock", output
  end
end
