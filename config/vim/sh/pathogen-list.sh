#!/bin/bash

# Lists packages installed by pathogen

cd ~/.vim/bundle

PACKAGES=$(ls)

for PACKAGE in $(ls); do
    URL=$(cat ./$PACKAGE/.git/config | grep 'url' | sed 's/url =//' | sed 's/ //g')
    echo $URL
done

