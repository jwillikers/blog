default: serve

alias b := build

build:
    jekyll build

alias c := check

check: build && format
    yamllint .
    asciidoctor {CODE_OF_CONDUCT,LICENSE,README}.adoc
    lychee --cache _site/ *.html

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
    nix flake update
    bundle update
    bundix
    nix fmt
