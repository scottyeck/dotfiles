#!/bin/bash

# Sync pathogen packages

BUNDLE=~/.vim/bundle
SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd)"
WANT_PKG="$( cat $SCRIPTPATH/../pathogenrc )"

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

