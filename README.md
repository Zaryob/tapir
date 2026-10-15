# Tapir

Homebrew packages for [Zaryob's projects](https://github.com/Zaryob).

## Install

```sh
brew tap zaryob/tapir https://github.com/Zaryob/tapir.git
brew install --cask zaryob/tapir/imshark
```

The explicit Git URL is required because this repository is named `tapir`.

| Package | Type | Requirements | Project |
| --- | --- | --- | --- |
| `imshark` | Cask | Apple Silicon, macOS 15 Sequoia or later | [ImShark](https://github.com/Zaryob/imshark) |

ImShark installs `imshark.app` and the `imshark` terminal command. Its current release is ad hoc signed and is not notarized. Open the app from Applications and, if macOS blocks it, allow it in System Settings > Privacy & Security > Open Anyway before using the app or CLI.

```sh
brew update
brew upgrade --cask zaryob/tapir/imshark

brew uninstall --cask zaryob/tapir/imshark
brew untap zaryob/tapir
```

## Add a project

One tap can hold packages from multiple repositories. Add each installable project separately:

- Put command-line tools and packages built from source in `Formula/<package>.rb`.
- Put published macOS app bundles and installers in `Casks/<package>.rb`.
- Point each definition at its project's versioned release and pin its SHA-256 checksum. Include required build/runtime dependencies for formulae and supported platforms for casks.
- Add the package to the table above and extend CI with an installation check for it.

The repository contains package definitions. Application sources and release binaries remain in their respective project repositories.

## Maintaining packages

After an upstream release has been published, download its package and checksum manifest. Verify the download with `shasum -a 256 <package>`, then update the definition's `version` and `sha256`. Check deployment targets and architectures before changing platform requirements. An upstream release does not update this tap automatically.

From this repository's checkout, with ImShark uninstalled, test pending changes using a separate local tap:

```sh
brew tap --custom-remote tapir/local "$PWD"
cp Casks/imshark.rb "$(brew --repository tapir/local)/Casks/imshark.rb"
brew style tapir/local
brew audit --tap=tapir/local --online
brew fetch --cask tapir/local/imshark

tapir_appdir="$(mktemp -d)"
brew install --cask --require-sha --appdir="$tapir_appdir" tapir/local/imshark
test "$(brew --prefix)/bin/imshark" -ef "$tapir_appdir/imshark.app/Contents/MacOS/imshark"
codesign --verify --deep --strict "$tapir_appdir/imshark.app"
```

Open the app from the temporary directory and complete macOS first-launch approval before checking its GUI and running `imshark --version` or `imshark --help`. Then clean up:

```sh
brew uninstall --cask tapir/local/imshark
rmdir "$tapir_appdir"
brew untap tapir/local
```

The temporary app directory avoids replacing `/Applications/imshark.app`; the CLI link still uses Homebrew's normal `bin` directory. Cask installation preserves quarantine. The [workflow](.github/workflows/homebrew.yml) checks style, audits packages, installs ImShark, verifies its CLI link, bundle metadata and signature, and uninstalls it. Runtime checks require interactive approval and remain part of the manual procedure.

Commit and push validated changes to `main`; users receive them through `brew update`. ImShark's `livecheck` detects published upstream releases for maintainer checks and does not rewrite the cask.

See the official [tap guide](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap), [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) and [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) for package conventions.
