{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.vscode;
in
{
  options.vscode = {
    enable = mkEnableOption "nix-ld configuration";
    user = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    home-manager.users.${cfg.user}.home.file.".vscode-server/server-env-setup".text = ''
      PATH=$PATH:/run/current-system/sw/bin
      export PATH
      NX_LD_LIBRARY_PATH="${config.environment.variables.NIX_LD_LIBRARY_PATH}"
      export NX_LD_LIBRARY_PATH
      NIX_LD="${config.environment.variables.NIX_LD}"
      export NIX_LD
    '';
  };
}
