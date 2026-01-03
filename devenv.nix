{ pkgs, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{
  packages = with pkgs-unstable; [
    gleam
    beamMinimal27Packages.erlang
    beamMinimal27Packages.rebar3

    inotify-tools

    dbmate
    sqlite
  ];

  languages.javascript.pnpm.enable = true;

  env.DATABASE_URL = "sqlite:db/main.db";
}


