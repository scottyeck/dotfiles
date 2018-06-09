#!/bin/bash

SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd )"

# Install semantic-commits
mkdir -p .cache
git clone .cache/git-semantic-commits git@github.com:fteem/git-semantic-commits.git

# Symlink vimrc
ln -sf $SCRIPTPATH/vimrc ~/.vimrc
ln -sf $SCRIPTPATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPTPATH/bashrc ~/.bashrc
ln -sf $SCRIPTPATH/zshrc ~/.zshrc
