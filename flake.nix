{
  description = "resume";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = inputs@{ self, ... }:
    let
      eachSystem = systems: f:
        let
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key:
                let
                  appendSystem = key: system: ret: { ${system} = ret.${key}; };
                in attrs // {
                  ${key} = (attrs.${key} or { })
                    // (appendSystem key system ret);
                };
            in builtins.foldl' op attrs (builtins.attrNames ret);
        in builtins.foldl' op { } systems;
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in eachSystem defaultSystems (system:
      let
        pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
        resume = pkgs.stdenv.mkDerivation {
          name = "mydoc";
          buildInputs = [
            (pkgs.texlive.combine {
              inherit (pkgs.texlive)
                scheme-small

                # Add other LaTeX libraries (packages) here as needed, e.g:
                # stmaryrd amsmath pgf
                enumitem xifthen ifmtarg fontawesome sourcesanspro tcolorbox
                environ needspace soul wrapfig biblatex

                # build tools
                latexmk;
            })
            pkgs.glibcLocales
            pkgs.font-awesome_4
            pkgs.roboto
          ];
          src = ./src;
          buildPhase = ''
            mkdir -p fonts
            cp ${pkgs.font-awesome_4}/share/fonts/opentype/* fonts/
            cp ${pkgs.roboto}/share/fonts/truetype/* fonts/
            make
          '';

          meta = with pkgs.lib; {
            description = "Describe your document here";
            license = licenses.bsd3;
            platforms = platforms.darwin;
          };
        };
      in {
        packages = { inherit resume; };
        defaultPackage = resume;
      });
}
