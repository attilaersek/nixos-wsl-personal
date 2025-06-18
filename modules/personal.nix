{
  config,
  pkgs,
  ...
}:
{
  config =
    let
      user = "retk";
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
        etc."wsl.conf".text = '''';
        systemPackages = with pkgs; [
          wget
          curl
          jq
          yq
          findutils
          git
          unzip
          zip
          wslu
          xterm
        ];
      };

      home-manager.users.${user} = {
        programs = {
          git = {
            enable = true;
            extraConfig = {
              user = {
                name = "Attila Ersek";
                email = "ersek.attila@hotmail.com";
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
            extraConfig = ''
              Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
            '';
          };
        };
        services = {
          ssh-agent = {
            enable = true;
          };
          gpg-agent = {
            enable = true;
            enableSshSupport = true;
            enableBashIntegration = true;
            defaultCacheTtl = 60 * 60 * 4;
            maxCacheTtl = 60 * 60 * 8;
            pinentry.package = pkgs.pinentry-curses;
          };
        };
        home = {
          packages = with pkgs; [
            lastpass-cli
          ];
          stateVersion = "${config.system.nixos.release}";
          sessionVariables = {
            BROWSER = "wslview";
          };
        };
      };

      users.users.${user}.extraGroups = [ "docker" ];

      vscode = {
        inherit user;
        enable = true;
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
        starship.enable = true;
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
        package = pkgs.nixVersions.nix_2_29;
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
