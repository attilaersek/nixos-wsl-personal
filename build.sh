#!/usr/bin/env bash
set -euo pipefail

nix build .#nixosConfigurations.default.config.system.build.tarballBuilder
sudo ./result/bin/nixos-wsl-tarball-builder
