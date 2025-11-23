{ lib, config, pkgs, ... }:

let
  cfg = config.programs.freeshow;
in
{
  options.programs.freeshow.enable =
    lib.mkEnableOption "FreeShow presentation software";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.freeshow ];
  };
}
