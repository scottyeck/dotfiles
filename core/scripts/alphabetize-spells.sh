#!/bin/bash

# Alphabetizes items in my vim spellfile. Nothing fancy.

SPELLFILE=rc/spell/en.utf-8.add
cat $SPELLFILE | sort | sponge $SPELLFILE

