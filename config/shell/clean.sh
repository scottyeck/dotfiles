#!/bin/bash

[[ -e ~/.vimrc ]] && unlink ~/.vimrc
[[ -e ~/.pathogenrc]] && unlink ~/.pathogenrc
[[ -e ~/.bashrc]] && unlink ~/bashrc.
[[ -e ~/.zshrc]] && unlink ~/.zshrc

rm -rf ~/git/me/bag-of-tricks/.cache