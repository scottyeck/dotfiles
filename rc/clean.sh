#!/bin/bash

source ./common.sh

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
maybeUnlink ~/.zshenv
maybeUnlink ~/.gitconfig
maybeUnlink $CONFIG_PATH/nvim/init.vim
maybeUnlink $CONFIG_PATH/coc/extensions/package.json
maybeUnlink $TODO_CONFIG_PATH/todo.cfg
maybeUnlink $VIM_CONFIG_PATH/ftplugin
maybeUnlink $VIM_CONFIG_PATH/spell

# TODO: Destroy pathogen deps under ~/.vim
