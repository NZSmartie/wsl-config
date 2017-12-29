SSH_ENV="$HOME/.ssh/environment"

export GOPATH=$HOME/.golang
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

function start_agent {
    echo "starting ssh-agent..."
    
    LISTEN_SOCKET=$(mktemp -p /tmp -d ssh-XXXXXXXXXXXX)
    socat UNIX-LISTEN:$LISTEN_SOCKET/wsl-ssh-pageant.socket,unlink-close,unlink-early,mode=600,fork EXEC:"wsl-ssh-pagent.exe" &
    SOCAT_PID=$!
    cat > "${SSH_ENV}" <<EOL
export SSH_AGENT_PID=${SOCAT_PID}; export SSH_AGENT_PID
export SSH_AUTH_SOCK=$LISTEN_SOCKET/wsl-ssh-pageant.socket;export SSH_AUTH_SOCK
EOL

    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps ${SSH_AGENT_PID} > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

GPG_PRESENT=$(nc -w 1 -U $HOME/.gnupg/S.gpg-agent 2>/dev/null)
if [[ $GPG_PRESENT != OK* ]]; then
    echo "starting gpg-agent..."
    rm $HOME/.gnupg/S.gpg-agent
    socat UNIX-LISTEN:/home/roman/.gnupg/S.gpg-agent,fork, EXEC:'npiperelay.exe -ei -ep -s "C:/Users/nzsma/AppData/Roaming/gnupg/S.gpg-agent"',nofork &
fi
