#!/bin/bash

function removeGitAliases () {
  git config --get-regexp alias | awk '{print $1}' | xargs -I {} git config --global --unset {}
}

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

removeGitAliases

rm -rf ~/git/me/bag-of-tricks/.cache
