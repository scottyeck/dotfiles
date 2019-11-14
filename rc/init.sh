#!/bin/bash

source ./common.sh

# Symlink homedir root rc's
ln -sf $SCRIPT_PATH/vimrc ~/.vimrc
ln -sf $SCRIPT_PATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPT_PATH/bashrc ~/.bashrc
ln -sf $SCRIPT_PATH/zshrc ~/.zshrc
ln -sf $SCRIPT_PATH/gitconfig ~/.gitconfig

# Setup homedir config rc's
mkdir -p $CONFIG_PATH/nvim
ln -sf $SCRIPT_PATH/init.vim $CONFIG_PATH/nvim/init.vim

# Setup todo.txt config
mkdir -p $TODO_CONFIG_PATH
ln -sf $SCRIPT_PATH/todo.cfg $TODO_CONFIG_PATH/todo.cfg

# Setup vim lang-specific settings
mkdir -p $VIM_CONFIG_PATH
ln -sf $SCRIPT_PATH/ftplugin $VIM_CONFIG_PATH/ftplugin
ln -sf $SCRIPT_PATH/spell $VIM_CONFIG_PATH/spell

# Setup coc config
mkdir -p $CONFIG_PATH/coc/extensions
ln -sf $SCRIPT_PATH/coc.json $CONFIG_PATH/coc/extensions/package.json
echo "coc extensions configured. Please install by running:"
echo "cd $CONFIG_PATH/coc/extensions && npm install"

# Install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# TODO:
# Set up setup / teardown fns for each rc rather than having
# everything littered together here.
