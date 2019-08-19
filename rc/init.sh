#!/bin/bash

SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd )"

# Symlink vimrc
ln -sf $SCRIPTPATH/vimrc ~/.vimrc
ln -sf $SCRIPTPATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPTPATH/bashrc ~/.bashrc
ln -sf $SCRIPTPATH/zshrc ~/.zshrc
ln -sf $SCRIPTPATH/todo.cfg ~/.todo/config
