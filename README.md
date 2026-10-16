# Tapir

Homebrew packages for [Zaryob's projects](https://github.com/Zaryob).

## Install

```sh
brew tap zaryob/tapir https://github.com/Zaryob/tapir.git
brew install --cask zaryob/tapir/imshark
```

The explicit Git URL is required because this repository is named `tapir`.
If your Homebrew version requires tap trust, run `brew trust zaryob/tapir` after the tap command and before installing packages.

| Package | Type | Requirements | Project |
| --- | --- | --- | --- |
| `imshark` | Cask | Apple Silicon, macOS 15 Sequoia or later | [ImShark](https://github.com/Zaryob/imshark) |
| `sdrsentinel` | Cask / Formula | macOS 12 Monterey or later (Apple Silicon & Intel) | [SDRSentinel](https://github.com/Zaryob/SDRPlusPlus) |
| `docker-tui` | Formula | macOS or Linux; a running Docker daemon | [docker-tui](https://github.com/Zaryob/docker-tui) |
| `iksemel-rs` | Formula | macOS or Linux; Rust is needed to build | [iksemel-rs](https://github.com/Zaryob/iksemel-rs) |
| `iksemel` | Formula | macOS or Linux; C XML parser library | [iksemel](https://github.com/Zaryob/iksemel) |
| `performer-viewer` | Formula | macOS or Linux with a graphical browser | [Performer](https://github.com/Zaryob/Performer) |

Install the command-line tools, C library, and offline viewer with:

```sh
brew install zaryob/tapir/docker-tui
brew install zaryob/tapir/iksemel-rs
brew install zaryob/tapir/iksemel
brew install zaryob/tapir/performer-viewer
```

`docker-tui` connects to an existing Docker daemon, including Docker Desktop or Colima. Its full-screen shell, image builds, and build history also need the Docker CLI with buildx. The formula builds the tagged source with Go.

`iksemel-rs` installs `ikslint`, `iksperf`, and `iksroster` from the published Rust crate, using its bundled dependency lockfile. The C `iksemel` formula installs the library, headers, and pkg-config metadata with TLS and Python bindings disabled. It does not install the C tools, so both implementations can coexist. For a C consumer, use `pkg-config --cflags --libs iksemel-1.6.2` after installing `pkgconf`.

Run `performer-viewer` to open the self-contained viewer, then select or drop a Performer `.tgz` bundle in the browser. `performer-viewer --print-path` prints the installed HTML path without opening it. The formula installs the prebuilt HTML from the tagged source archive and needs no Node.js or local server. The Linux-only measurement collector is distributed separately.

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
if brew command trust >/dev/null 2>&1; then brew trust --cask tapir/local/imshark; fi
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

The temporary app directory avoids replacing `/Applications/imshark.app`; the CLI link still uses Homebrew's normal `bin` directory. Cask installation preserves quarantine. The [workflow](.github/workflows/homebrew.yml) checks style, audits packages, installs ImShark, verifies its CLI link, bundle metadata and signature, and uninstalls it. ImShark runtime checks require interactive approval and remain part of the manual procedure. Separate jobs build, install, test, and uninstall each of the four additional formulae on macOS and Linux.

To test a new formula from this checkout, register the local tap as above and copy the definition before installing it:

```sh
brew tap --custom-remote tapir/local "$PWD"
cp Formula/docker-tui.rb "$(brew --repository tapir/local)/Formula/docker-tui.rb"
if brew command trust >/dev/null 2>&1; then brew trust --formula tapir/local/docker-tui; fi
brew style tapir/local/docker-tui
brew audit --formula --strict --online tapir/local/docker-tui
brew install --formula --build-from-source tapir/local/docker-tui
brew test tapir/local/docker-tui
brew uninstall --formula tapir/local/docker-tui
brew untap tapir/local
```

Repeat with `iksemel-rs`, `iksemel`, or `performer-viewer` to exercise their package tests. The XML tools and C library tests run offline; the viewer test checks its launcher and bundled HTML without opening a browser, and the Docker TUI test uses a nonexistent socket instead of a live daemon.

The full-tap online audit currently reports GitHub 404 for SDRSentinel's configured upstream. Restore access to that repository and release before expecting the full-tap audit to pass. The four additional formulae are audited independently in CI.

Commit and push validated changes to `main`; users receive them through `brew update`. ImShark's `livecheck` detects published upstream releases for maintainer checks and does not rewrite the cask.

See the official [tap guide](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap), [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) and [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) for package conventions.
