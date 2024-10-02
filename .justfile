default: serve

alias f := format
alias fmt := format

format:
    just --fmt --unstable

alias l := lint

lint:
    yamllint .

alias b := build

build:
    jekyll build

alias s := serve

serve:
    jekyll serve --open-url

alias u := update
alias up := update

update:
    bundle update
    bundix
    pre-commit autoupdate
