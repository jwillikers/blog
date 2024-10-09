default: serve

alias f := format
alias fmt := format

format:
    treefmt

alias l := lint

lint:
    yamllint .

alias b := build

build:
    jekyll build

alias s := serve

serve:
    jekyll serve --open-url

alias t := test

test:
    nu update-nixos-release-tests.nu

alias u := update
alias up := update

update: && build test
    nu update-nixos-release.nu
    nix flake update
    bundle update
    bundix
