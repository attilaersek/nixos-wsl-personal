#!/usr/bin/env bash
set -euo pipefail

sudo -E nix run path:.#nixosConfigurations.default.config.system.build.tarballBuilder
