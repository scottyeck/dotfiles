#!/bin/bash

SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd )"

# Symlink homedir root rc's
ln -sf $SCRIPTPATH/vimrc ~/.vimrc
ln -sf $SCRIPTPATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPTPATH/bashrc ~/.bashrc
ln -sf $SCRIPTPATH/zshrc ~/.zshrc
ln -sf $SCRIPTPATH/gitconfig ~/.gitconfig

CONFIGPATH=~/.config

# Setup homedir config rc's
mkdir -p $CONFIGPATH/nvim
ln -sf $SCRIPTPATH/init.vim $CONFIGPATH/nvim/init.vim

# Install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
