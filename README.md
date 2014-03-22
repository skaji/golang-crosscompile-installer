# go installer with crosscompile support

This script helps you install go with crosscompile support.

Must see https://github.com/davecheney/golang-crosscompile.

## Usage

Just one liner:

    > curl https://raw.githubusercontent.com/shoichikaji/golang-crosscompile-installer/master/installer.pl | perl -

This installs go 1.2.1 to ~/.go with crosscompile support.
Don't foget to set the followings in your .bashrc or .zshrc:

    export PATH=~/.go/bin:$PATH
    source ~/.go/misc/golang-crosscompile/crosscompile.bash

For example, to build `main.go` for `freebsd-386`, type:

    > go-freebsd-386 build main.go

## Requirements

* c compiler
* curl
* tar
* perl

## Author

Shoichi Kaji
