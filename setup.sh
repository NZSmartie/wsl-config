#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ln -s $(realpath $DIR/.screenrc) $HOME/.screenrc
ln -s $(realpath $DIR/.vimrc) $HOME/.vimrc
ln -s $(realpath $DIR/.bash_profile) $HOME/.bash_profile 
