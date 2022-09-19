{
  # main
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # dev
  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        inherit (pkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            fenix.overlay
            nix-filter.overlays.default
          ];
        };
      in {
        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            nodejs-16_x
            treefmt
            (fenix.latest.withComponents [
              "cargo"
              "rustc"
              "rustfmt"
            ])
            pkg-config
            glib
            dbus
            cairo
            atk
            openssl
            libsoup
            pango
            gdk-pixbuf
            gtk3
            harfbuzz
            zlib
          ];
          commands = [
            {
              package = "treefmt";
              category = "formatters";
            }
          ];
          env = [
            {
              name = "PATH";
              eval = "$PATH:$PRJ_ROOT/node_modules/.bin";
            }
            {
              name = "PKG_CONFIG_PATH";
              eval = builtins.concatStringsSep ":" (
                with pkgs; [
                  "${atk.dev}/lib/pkgconfig"
                  "${cairo.dev}/lib/pkgconfig"
                  "${dbus.dev}/lib/pkgconfig"
                  "${gdk-pixbuf.dev}/lib/pkgconfig"
                  "${glib.dev}/lib/pkgconfig"
                  "${gtk3.dev}/lib/pkgconfig"
                  "${harfbuzz.dev}/lib/pkgconfig"
                  "${libsoup.dev}/lib/pkgconfig"
                  "${openssl.dev}/lib/pkgconfig"
                  "${pango.dev}/lib/pkgconfig"
                  "${webkitgtk.dev}/lib/pkgconfig"
                  "${zlib.dev}/lib/pkgconfig"
                ]
              );
            }
          ];
        };
      }
    );
}
