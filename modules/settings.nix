{ lib, ... }:
{
  options.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "wsluser";
      description = "The username for the user.";
    };
    git = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The name for git commits.";
      };
      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The email for git commits.";
      };
    };
  };
}
