#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 0
fi

cp .startup.sh $HOME/.startup.sh
chown root:$SUDO_GID $HOME/.startup.sh
chmod go-w,a+x $HOME/.startup.sh

echo "Please add the following entry to sudoers via visudo"
echo "$SUDO_USER ALL=(root) NOPASSWD: $HOME/.startup.sh"

declare -a RCFILES=(
    .gitconfig
    .pythonrc
    .screenrc
    .vimrc
    .bash_profile
)

for rcfile in "${RCFILES[@]}"
do
    cp $DIR/$rcfile $HOME/
    chown $SUDO_UID:$SUDO_GID $HOME/$rcfile
done

