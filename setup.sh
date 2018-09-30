#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 0
fi

cp .startup.sh $HOME/.startup.sh
chown root $HOME/.startup.sh
chmod go-w,a+x $HOME/.startup.sh

echo "Please add the following entry to sudoers via visudo"
echo "$SUDO_USER ALL=(root) NOPASSWD: $HOME/.startup.sh"

cp $DIR/.gitconfig $HOME/.gitconfig
cp $DIR/.pythonrc $HOME/.pythonrc
cp $DIR/.screenrc $HOME/.screenrc
cp $DIR/.vimrc $HOME/.vimrc
cp .bash_profile $HOME/.bash_profile

