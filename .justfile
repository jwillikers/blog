default: serve

alias b := build

build:
    jekyll build

alias c := check

check: build && format
    yamllint .
    asciidoctor {CODE_OF_CONDUCT,LICENSE,README}.adoc
    lychee --cache _site/ *.html
    nix flake check

alias f := format
alias fmt := format

format:
    treefmt

alias s := serve

serve:
    jekyll serve --open-url

alias u := update
alias up := update

update:
    nix run ".#update-nix-direnv"
    nix run ".#update-nixos-release"
    nix flake update
    bundle update
    bundix
    nix fmt
