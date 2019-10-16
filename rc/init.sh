#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname $0 )" ; pwd )"

# Symlink homedir root rc's
ln -sf $SCRIPT_PATH/vimrc ~/.vimrc
ln -sf $SCRIPT_PATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPT_PATH/bashrc ~/.bashrc
ln -sf $SCRIPT_PATH/zshrc ~/.zshrc
ln -sf $SCRIPT_PATH/gitconfig ~/.gitconfig

CONFIG_PATH=~/.config

# Setup homedir config rc's
mkdir -p $CONFIG_PATH/nvim
ln -sf $SCRIPT_PATH/init.vim $CONFIG_PATH/nvim/init.vim

# Setup todo.txt config
TODO_CONFIG_PATH=~/.todo
mkdir -p $TODO_CONFIG_PATH
ln -sf $SCRIPT_PATH/todo.cfg $TODO_CONFIG_PATH/todo.cfg

# Install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
