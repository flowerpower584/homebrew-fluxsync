# typed: true
# frozen_string_literal: true

# Homebrew formula for FluxSync.
#
# Lives in this repo so the source-of-truth + the install pipeline stay
# in lock-step. The published copy lives in the tap at
# `flowerpower584/homebrew-fluxsync` so that
# `brew install flowerpower584/fluxsync/fluxsync` resolves.
#
# Until pre-built bottles ship, this is a from-source build via
# `cargo install` (the workspace resolves deps once, links static).
#
# Usage:
#   brew tap flowerpower584/fluxsync
#   brew install fluxsync
#   brew services start fluxsync
class Fluxsync < Formula
  desc "Universal clipboard, local-first, peer-to-peer"
  homepage "https://github.com/flowerpower584/fluxsync"
  url "https://github.com/flowerpower584/fluxsync/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "c1688c566f87f0041acc17e2a335b3fa5b03ab376c5826f81b21f3784a91d89e"
  license "MIT"
  head "https://github.com/flowerpower584/fluxsync.git", branch: "main"

  depends_on "rust" => :build
  depends_on "node" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/fluxsyncd")
    system "cargo", "install", *std_cargo_args(path: "crates/fluxctl")

    cd "apps/macos-tray" do
      system "npm", "install", "--no-audit", "--no-fund"
      system "npx", "tauri", "build", "--bundles", "app"
      app_src = "src-tauri/target/release/bundle/macos/FluxSync.app"
      odie "Tauri build did not produce #{app_src}" unless File.exist?(app_src)
      prefix.install app_src
    end

    (var/"fluxsync").mkpath
  end

  def caveats
    <<~EOS
      The FluxSync menu-bar app was built locally (no Apple notarisation
      required) and installed to:
        #{opt_prefix}/FluxSync.app

      Move it to /Applications (or symlink) to launch from Spotlight:
        ln -sfn #{opt_prefix}/FluxSync.app /Applications/FluxSync.app

      Or open it now:
        open #{opt_prefix}/FluxSync.app
    EOS
  end

  service do
    run [opt_bin/"fluxsyncd"]
    keep_alive true
    log_path var/"log/fluxsync.log"
    error_log_path var/"log/fluxsync.err"
    working_dir var/"fluxsync"
    environment_variables HOME: Dir.home
  end

  test do
    assert_match "fluxctl", shell_output("#{bin}/fluxctl --help")
    assert_match "fluxsyncd", shell_output("#{bin}/fluxsyncd --help")
    assert_predicate prefix/"FluxSync.app/Contents/MacOS/fluxsync-macos-tray", :exist?
  end
end
