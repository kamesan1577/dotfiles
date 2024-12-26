#!/bin/bash

DOT_FILES=($(ls -A))

for file in ${DOT_FILES[@]}
do
  if [[ $file == .* ]]; then
    ln -sf $HOME/dotfiles/$file $HOME/$file
  fi
done
