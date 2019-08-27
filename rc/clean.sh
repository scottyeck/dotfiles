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

# TODO: Destroy pathogen deps under ~/.vim
