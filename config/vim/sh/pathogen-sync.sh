#!/bin/bash

# Sync pathogen packages

BUNDLE=~/.vim/bundle
# TODO:
# Fix this path
WANT_PKG=$(cat ~/git/me/bag-of-tricks/config/vim/pathogenrc)

getName () {
    local PKG=$1
    NAME="${PKG##*/}"
    NAME="${NAME%.git}"
    echo $NAME
}

clonePkg () {
    local URL=$1
    CMD="cd $BUNDLE && git clone $URL"
    eval $CMD
}

syncPkg () {
    for PKG in $WANT_PKG; do
        NAME=$(getName $PKG)
        [[ -e $BUNDLE/$NAME ]] || clonePkg $PKG
    done
}

syncPkg

