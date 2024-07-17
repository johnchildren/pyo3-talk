{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "package";

  buildInputs = with pkgs; [mdbook marksman];
}
