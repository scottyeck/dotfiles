#!/bin/bash

[[ -e ~/.vimrc ]] && unlink ~/.vimrc
[[ -e ~/.pathogenrc]] && unlink ~/.pathogenrc
[[ -e ~/.bashrc]] && unlink ~/bashrc.
[[ -e ~/.zshrc]] && unlink ~/.zshrc
