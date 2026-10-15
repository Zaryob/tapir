cask "sdrsentinel" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/Zaryob/SDRPlusPlus/releases/download/v#{version}/sdrsentinel-macos-arm64.zip"
  name "SDRSentinel"
  desc "Passive RF signal characterization, pulse analysis, and direction finding suite"
  homepage "https://github.com/Zaryob/SDRPlusPlus"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"

  app "SDRSentinel.app"
  binary "#{appdir}/SDRSentinel.app/Contents/MacOS/sdrpp", target: "sdrsentinel"

  zap trash: [
    "~/Library/Preferences/org.sdrsentinel.app.plist",
    "~/Library/Saved Application State/org.sdrsentinel.app.savedState",
  ]

  caveats <<~EOS
    SDRSentinel is ad-hoc signed and is not notarized. If macOS blocks the first
    launch, allow it in System Settings > Privacy & Security > Open Anyway.
  EOS
end
