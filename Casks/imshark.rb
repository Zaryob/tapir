cask "imshark" do
  version "1.0.1"
  sha256 "f55c35798ceb3c27a559a6f0cf56995a55a9425ef7120fbfa7ea97594dd982f4"

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
