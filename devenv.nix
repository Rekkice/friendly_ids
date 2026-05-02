{ pkgs, ... }:

{
  packages = with pkgs; [
    gleam
    beamMinimal27Packages.erlang
    beamMinimal27Packages.rebar3

    inotify-tools
  ];

  languages.javascript.pnpm.enable = true;

  env.DATABASE_URL = "sqlite:db/main.db";
}


