{
  config,
  pkgs,
  ...
}:
{
  config =
    let
      user = config.settings.username;
    in
    {
      wsl = {
        usbip.enable = true;
        defaultUser = user;
        docker-desktop.enable = false;
        extraBin = with pkgs; [
          { src = "${coreutils}/bin/rm"; }
          { src = "${coreutils}/bin/mkdir"; }
          { src = "${coreutils}/bin/date"; }
          { src = "${coreutils}/bin/mkdir"; }
          { src = "${coreutils}/bin/uname"; }
          { src = "${coreutils}/bin/readlink"; }
          { src = "${coreutils}/bin/dirname"; }
          { src = "${coreutils}/bin/ls"; }
          { src = "${coreutils}/bin/whoami"; }
          { src = "${coreutils}/bin/cat"; }
          { src = "${coreutils}/bin/wc"; }
          { src = "${coreutils}/bin/sleep"; }
          { src = "${coreutils}/bin/mv"; }
          { src = "${bash}/bin/bash"; }
          { src = "${shadow}/bin/usermod"; }
          { src = "${shadow}/bin/groupadd"; }
          { src = "${busybox}/bin/addgroup"; }
          { src = "${xterm}/bin/xterm"; }
          { src = "${gzip}/bin/gzip"; }
          { src = "${gnutar}/bin/tar"; }
          { src = "${gnused}/bin/sed"; }
        ];
      };

      environment = {
        etc."wsl.conf".text = "";
        systemPackages = with pkgs; [
          wget
          curl
          jq
          yq
          findutils
          git
          unzip
          zip
          xterm
          xdg-utils
        ];
      };

      home-manager.users.${user} = {
        programs = {
          bash = {
            enable = true;
            historyControl = [ "ignoreboth" ];
          };
          eza = {
            enable = true;
            enableBashIntegration = true;
            git = true;
            colors = "always";
            icons = "always";
          };
          fzf = {
            enable = true;
            enableBashIntegration = true;
          };
          zoxide = {
            enable = true;
            enableBashIntegration = true;
          };
          starship = {
            enable = true;
            enableBashIntegration = true;
            settings = {
              kubernetes = {
                disabled = false;
              };
              status = {
                disabled = false;
                style = "bg:blue";
                symbol = "🔴 ";
                format = "[\\[$symbol$common_meaning$signal_name$maybe_int\\]]($style)";
                map_symbol = true;
              };
            };
          };
          git = {
            enable = true;
            settings = {
              user = pkgs.lib.filterAttrs (_: v: v != null) {
                inherit (config.settings.git) name email;
              };
              commit = {
                gpgSign = true;
              };
              init = {
                defaultBranch = "main";
              };
              merge = {
                conflictStyle = "zdiff3";
              };
              push = {
                autoSetupRemote = true;
              };
            };
          };
          gpg = {
            enable = true;
          };
          ssh = {
            enable = true;
            enableDefaultConfig = false;
            settings."*" = {
              ForwardAgent = false;
              AddKeysToAgent = "no";
              Compression = false;
              ServerAliveInterval = 0;
              ServerAliveCountMax = 3;
              HashKnownHosts = false;
              UserKnownHostsFile = "~/.ssh/known_hosts";
              ControlMaster = "no";
              ControlPath = "~/.ssh/master-%r@%n:%p";
              ControlPersist = "no";
            };
            settings."Match host * exec \"gpg-connect-agent UPDATESTARTUPTTY /bye\"" = { };
          };
        };
        services = {
          gpg-agent = {
            enable = true;
            enableSshSupport = true;
            enableBashIntegration = true;
            defaultCacheTtl = 60 * 60 * 4;
            defaultCacheTtlSsh = 60 * 60 * 4;
            maxCacheTtl = 60 * 60 * 8;
            maxCacheTtlSsh = 60 * 60 * 8;
            pinentry.package = pkgs.pinentry-qt;
          };
          gnome-keyring.enable = true;
        };
        home = {
          shellAliases = {
            ll = "eza -la --group-directories-first --git";
            ls = "eza --group-directories-first --git";
            gs = "git status";
            gl = "git log --oneline --graph --decorate";
          };
          sessionPath = [
            "/home/${user}/.local/bin"
          ];
          packages = with pkgs; [
            gcr
          ];
          stateVersion = "${config.system.nixos.release}";
        };
      };

      users.users.${user}.extraGroups = [ "docker" ];

      vscode = {
        inherit user;
        enable = true;
      };

      boot.initrd.kernelModules = [ "amdgpu" ];

      services = {
        upower.enable = true;
        xserver.videoDrivers = [ "amdgpu" ];
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true; # Required for Steam / 32-bit apps

        # Extra packages for AMD hardware video acceleration (VA-API)
        extraPackages = with pkgs; [
          rocmPackages.clr.icd # OpenCL support (Optional, good for compute)
        ];
      };

      programs = {
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            zlib
            zstd
            stdenv.cc.cc
            curl
            openssl
            attr
            libssh
            bzip2
            libxml2
            acl
            libsodium
            util-linux
            xz
            systemd
            icu
          ];
        };
        bash = {
          shellInit = ''
            . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          '';
        };
        direnv.enable = true;
      };

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune.enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      nix = {
        package = pkgs.nixVersions.latest;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          trusted-users = [ user ];
          always-allow-substitutes = true;
          extra-sandbox-paths = [ "/usr/lib/wsl" ];
        };
      };
    };
}
