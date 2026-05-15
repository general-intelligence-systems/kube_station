{
  description = "brute — Ruby gem";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.kwatch = pkgs.buildGoModule {
          pname = "kwatch";
          version = "0.1.0";
          src = ./engines/kube_station/bin/kwatch;
          vendorHash = "sha256-pnvt4kM8Z0TmXUOdnW1kpgZxYKbnZ7Sv/j8z41t+SSE=";
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            ruby_3_4
            libyaml 
            openssl
            go
          ];

          shellHook = ''
            export GEM_HOME="$PWD/.gem"
            export GEM_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"
            export BUNDLE_PATH="$GEM_HOME"
            export BUNDLE_BIN="$GEM_HOME/bin"
          '';
        };
      }
    );
}
