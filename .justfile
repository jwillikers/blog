default: serve

alias c := check

check: build
    yamllint .
    lychee --cache _site/

alias f := format
alias fmt := format

format:
    treefmt

alias b := build

build:
    jekyll build

alias s := serve

serve:
    jekyll serve --open-url

alias t := test

test:
    nu update-nixos-release-tests.nu
    nu update-nix-direnv-tests.nu

alias u := update
alias up := update

update: && build test
    nu update-nixos-release.nu
    nix flake update
    bundle update
    bundix --magic
    nu update-nix-direnv.nu
