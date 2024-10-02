#!/usr/bin/env nu

export def get_latest_nixos_release [date: datetime] [ nothing -> string ] {
    let $date = $date | date to-timezone UTC | date to-record
    let month = (
        (
            if $date.month < 5 {
                11
            } else if $date.month < 11 {
                5
            } else {
                11
            }
        ) | into string | (
            if ($in | str length) < 2 {
                $"0($in)"
            } else {
                $in
            }
        )
    )
    let year = (
        (
            if $date.month < 5 {
                $date.year - 1
            } else {
                $date.year
            }
        ) | $in mod 100 | into string | (
            if ($in | str length) < 2 {
                $"0($in)"
            } else {
                $in
            }
        )
    )
    $"($year).($month)"
}

export def update_nixos_release_in_flake [
    release: string # NixOS release, i.e. 24.05
] [ string -> string ] {
    $in | str replace --regex "github:NixOS/nixpkgs/nixos-[0-9][0-9].[0-9][0-9]" $"github:NixOS/nixpkgs/nixos-($release)"
}

def main [
    flake_file: string # Path to the flake.nix file to update
] {
    let release = get_latest_nixos_release (date now)
    let flake_file = (
        if ($flake_file | is-empty) {
            $env.FILE_PWD | path join "flake.nix"
        } else {
            $flake_file
        }
    )
    open $flake_file | update_nixos_release_in_flake $release | save --force $flake_file
    exit 0
}
