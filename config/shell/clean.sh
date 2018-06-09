#!/bin/bash

function maybeUnlink () {
  FILE=$1
  if [ -f $FILE ]; then
    echo "unlinking $FILE"
    unlink $FILE
  fi
}

maybeUnlink ~/.vimrc
maybeUnlink ~/.pathogenrc
maybeUnlink ~/.bashrc
maybeUnlink ~/.zshrc

rm -rf ~/git/me/bag-of-tricks/.cache