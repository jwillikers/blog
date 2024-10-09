#!/usr/bin/env nu
use update-nixos-release.nu get_latest_nixos_release
use update-nixos-release.nu update_nixos_release_in_flake

use std assert

def test_get_latest_nixos_release [] {
    for t in [
        [input expected];
        [("2024-12-19" | into datetime) "24.11"]
        [("2024-11-01" | into datetime) "24.11"]
        [("2024-10-29" | into datetime) "24.05"]
        [("2024-05-01" | into datetime) "24.05"]
        [("2024-04-28" | into datetime) "23.11"]
        [("2024-04-29" | into datetime) "23.11"]
        [("2024-01-01" | into datetime) "23.11"]
        [("2000-01-01" | into datetime) "99.11"]
        [("2000-06-06" | into datetime) "00.05"]
    ] {
        assert equal (get_latest_nixos_release $t.input) $t.expected
    }
}

def test_update_nixos_release_in_flake [] {
    for t in [
        [flake release expected];
        ['
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          nativeBuildInputs = with pkgs; [
          ];
          buildInputs = with pkgs; [
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        }
      );' "24.11" '
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          nativeBuildInputs = with pkgs; [
          ];
          buildInputs = with pkgs; [
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        }
      );']
    ] {
        assert equal ($t.flake | update_nixos_release_in_flake $t.release) $t.expected
    }
}

def main [] [] {
    test_get_latest_nixos_release
    test_update_nixos_release_in_flake
    echo "All tests passed!"
}
