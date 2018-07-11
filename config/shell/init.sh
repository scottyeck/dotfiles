#!/bin/bash

SCRIPTPATH="$( cd "$( dirname $0 )" ; pwd )"

# Install semantic-commits
mkdir -p .cache
git clone git@github.com:fteem/git-semantic-commits.git .cache/git-semantic-commits

# Symlink vimrc
ln -sf $SCRIPTPATH/vimrc ~/.vimrc
ln -sf $SCRIPTPATH/pathogenrc ~/.pathogenrc
ln -sf $SCRIPTPATH/bashrc ~/.bashrc
ln -sf $SCRIPTPATH/zshrc ~/.zshrc

# git aliases

# Lists the last 10 branches you worked on
# Run `git lastworks`
# https://gist.github.com/AvnerCohen/a25a69df4e13f469c4ee
git config --global alias.lastworks "for-each-ref --count=10 --sort=-committerdate refs/heads/"

# Lists semantic commits help
git config --global alias.sc git-sc
