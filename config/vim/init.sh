#!/bin/bash

SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd )"

# Symlink vimrc
ln -sf $SCRIPTPATH/vimrc ~/.vimrc

