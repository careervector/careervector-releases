# CareerVector releases

Native Linux x86-64 previews of both CareerVector products. Install both together: the TUI owns the terminal command; the desktop has its own application-menu entry.

| Product | Version | Start |
| --- | --- | --- |
| CareerVector desktop | 0.0.1 | CareerVector in the application menu |
| CareerVector TUI | 0.1.0-alpha.10 | `careervector` in a terminal |

## Install

| Channel | Command |
| --- | --- |
| Arch / CachyOS / AUR | `paru -S careervector careervector-tui-bin` |
| Nix desktop | `nix profile install github:julian-corbet/careervector-releases#careervector` |
| Nix TUI | `nix profile install github:julian-corbet/careervector-releases#careervector-tui` |
| Homebrew tap | `brew tap corbet-labs/careervector https://github.com/julian-corbet/homebrew-careervector` |
| Homebrew packages | `brew install corbet-labs/careervector/careervector corbet-labs/careervector/careervector-tui` |

Homebrew formulas are experimental: Ruby syntax and the underlying native archives were checked; actual `brew install` has not been verified. Arch systems should use the native AUR packages. Linux archives require GLIBC 2.39 or newer; the recipes supply the additional GUI libraries. Nix uses its own runtime libraries.

[Desktop release](https://github.com/julian-corbet/careervector-releases/releases/tag/desktop-v0.0.1) · [TUI release](https://github.com/julian-corbet/careervector-releases/releases/tag/tui-v0.1.0-alpha.10)

Each release carries checksums, source/build identities, runtime evidence and license notices. The TUI includes corresponding source and the ccht relinking kit, whose modified-library rebuild was exercised in CI. The shared CareerVector workspace connection is a subsequent TUI integration milestone.

These packages unpack existing binaries. They do not compile Rust on the receiving machine. Package managers own updates; desktop shortcuts launch the private executable, so they do not conflict with the TUI command. Native macOS, Windows and ARM packages are not included in this preview.

This repository contains release metadata and packaging, with applicable product/component licenses in each archive. It does not mirror the private application repository.
