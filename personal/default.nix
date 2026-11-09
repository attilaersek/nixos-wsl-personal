{ lib, ... }:
{
  imports = lib.optional (builtins.pathExists ./personal.nix) ./personal.nix;
}
