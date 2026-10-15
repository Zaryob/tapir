cask "imshark" do
  version "1.0.0"
  sha256 "5846b953e068d199496ba47409c3546b7e2177da38974386cf1e5fa66f31975b"

  url "https://github.com/Zaryob/imshark/releases/download/v#{version}/imshark-#{version}-macos-arm64.dmg"
  name "ImShark"
  desc "Network packet analyzer"
  homepage "https://github.com/Zaryob/imshark"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "imshark.app"
  binary "#{appdir}/imshark.app/Contents/MacOS/imshark"

  caveats <<~EOS
    ImShark is ad hoc signed and is not notarized. If macOS blocks the first
    launch, allow it in System Settings > Privacy & Security > Open Anyway.
  EOS
end
