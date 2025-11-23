{
  description = "Portable dev shell for your scripts repo";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    forAll = f: {
      x86_64-linux = f "x86_64-linux";
      aarch64-linux = f "aarch64-linux";
      x86_64-darwin = f "x86_64-darwin";
      aarch64-darwin = f "aarch64-darwin";
    };
  in {
    devShells = forAll (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.mkShell {
          # Tools your Makefile/scripts commonly need
          packages = with pkgs; [
            bashInteractive
            gnumake
            coreutils gnused gawk findutils
            git curl wget jq unzip
            zsh
            python312 python312Packages.pip
            nodejs_22  # modern Node so chatgpt-cli runs
            openssh
          ];

          shellHook = ''
            # Local npm prefix so global installs don’t need sudo
            export NPM_CONFIG_PREFIX="$PWD/.npm-global"
            export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

            # Optional local pipx style layout (kept in repo)
            export PIPX_HOME="$PWD/.pipx"
            export PIPX_BIN_DIR="$PWD/.pipx/bin"
            export PATH="$PIPX_BIN_DIR:$PATH"

            # Bring in your OpenAI key if you’ve created it already
            if [ -f "$HOME/.openai_api_key" ]; then
              . "$HOME/.openai_api_key"
            elif [ -f ".secrets/openai_api_key" ]; then
              export OPENAI_API_KEY="$(cat .secrets/openai_api_key)"
            fi

            echo "Dev shell ready:"
            echo "  node: $(node -v) | npm: $(npm -v) | python: $(python3 --version | awk '{print $2}')"
            echo "Tip: nix develop -c make chatgpt-all"
          '';
        };
      });
  };
}

