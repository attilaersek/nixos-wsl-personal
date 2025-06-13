{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
with lib;
let
  fs = pkgs.lib.fileset;
  configuration = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-wsl-personal-config";
    src = fs.toSource {
      root = ./..;
      fileset = fs.unions [
        ../modules/default.nix
        ../modules/tarball-builder.nix
        ../modules/personal.nix
        ../modules/vscode.nix
        ../flake.nix
        ../flake.lock
        ../assets/NixOS-WSL.ico
      ];
    };
    postInstall = ''
      cp -r . $out
    '';
  };
  icon = ../assets/NixOS-WSL.ico;
  iconPath = "/etc/nixos.ico";

  wsl-distribution-conf = pkgs.writeText "wsl-distribution.conf" (
    generators.toINI { } {
      oobe.defaultName = "NixOS";
      shortcut.icon = iconPath;
    }
  );
in
{
  # These options make no sense without the wsl-distro module anyway
  config = mkIf config.wsl.enable {
    system.build.tarballBuilder = lib.mkForce (
      pkgs.writeShellApplication {
        name = "nixos-wsl-tarball-builder";

        runtimeInputs = [
          pkgs.coreutils
          pkgs.e2fsprogs
          pkgs.gnutar
          pkgs.nixos-install-tools
          pkgs.pigz
          config.nix.package
        ];

        text = ''
          if ! [ $EUID -eq 0 ]; then
            echo "This script must be run as root!"
            exit 1
          fi

          # Use .wsl extension to support double-click installs on recent versions of Windows
          out=''${1:-nixos-wsl-personal.wsl}

          root=$(mktemp -p "''${TMPDIR:-/tmp}" -d nixos-wsl-tarball.XXXXXXXXXX)
          trap 'chattr -Rf -i "$root" || true && rm -rf "$root" || true' INT TERM EXIT

          chmod o+rx "$root"

          echo "[NixOS-WSL] Installing..."
          nixos-install \
            --root "$root" \
            --no-root-passwd \
            --system ${config.system.build.toplevel} \
            --substituters ""

          echo "[NixOS-WSL] Adding channel..."
          nixos-enter --root "$root" --command 'HOME=/root nix-channel --add https://nixos.org/channels/nixos-25.05 nixos'
          nixos-enter --root "$root" --command 'HOME=/root nix-channel --add https://github.com/nix-community/NixOS-WSL/archive/refs/heads/main.tar.gz nixos-wsl'
          nixos-enter --root "$root" --command 'HOME=/root nix-channel --add https://github.com/attilaersek/nixos-wsl-personal/archive/refs/heads/main.tar.gz nixos-wsl-personal'

          echo "[NixOS-WSL] Adding wsl-distribution.conf"
          install -Dm644 ${wsl-distribution-conf} "$root/etc/wsl-distribution.conf"
          install -Dm644 ${icon} "$root${iconPath}"

          echo "[NixOS-WSL] Adding configuration..."
          mkdir -p "$root/etc/nixos"
          cp -R ${lib.cleanSource configuration}/. "$root/etc/nixos"
          chmod -R u+w "$root/etc/nixos"

          echo "[NixOS-WSL] Compressing..."
          tar -C "$root" \
            -c \
            --sort=name \
            --mtime='@1' \
            --owner=0 \
            --group=0 \
            --numeric-owner \
            . \
          | pigz > "$out"
        '';
      }
    );
  };
}
