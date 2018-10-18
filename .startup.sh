#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 0
fi

mkdir -p /run/user/$SUDO_UID
chown $SUDO_UID:$SUDO_GID /run/user/$SUDO_UID
chmod go-rwx /run/user/$SUDO_UID

chown :dialout /dev/ttyS*
chmod g+rw /dev/ttyS*

/etc/init.d/screen-cleanup start
