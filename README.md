# homebrew-fluxsync

Homebrew tap for [FluxSync](https://github.com/flowerpower584/fluxsync) — universal clipboard, local-first, peer-to-peer, end-to-end encrypted.

## Install

```sh
brew tap flowerpower584/fluxsync
brew install fluxsync
brew services start fluxsync   # auto-start daemon at login
```

This builds `fluxsyncd` (daemon) and `fluxctl` (CLI) from source. Requires Rust at build time (Homebrew handles it via `depends_on "rust" => :build`).

## Quick check

```sh
fluxctl --help
fluxctl status
```

The macOS tray app and Android APK are distributed separately — see the [main repo](https://github.com/flowerpower584/fluxsync).
