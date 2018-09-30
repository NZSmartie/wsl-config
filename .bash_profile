SSH_ENV="$HOME/.ssh/environment"

export PYTHONSTARTUP=$HOME/.pythonrc
export PATH=$PATH:$HOME/.local/bin

USER_RUN=/run/user/$UID

if [ ! -d "$USER_RUN" ]; then
    $HOME/.startup.sh
fi

function start_agent {
    echo "starting ssh-agent..."
    
    mkdir -p $USER_RUN/.ssh
    chmod go-rwx $USER_RUN/.ssh
    socat UNIX-LISTEN:$USER_RUN/.ssh/wsl-ssh-pageant.socket,unlink-close,unlink-early,mode=600,fork EXEC:"wsl-ssh-pageant.exe" &
    SOCAT_PID=$!
    cat > "${SSH_ENV}" <<EOL
export SSH_AGENT_PID=${SOCAT_PID}; export SSH_AGENT_PID
export SSH_AUTH_SOCK=$USER_RUN/.ssh/wsl-ssh-pageant.socket;export SSH_AUTH_SOCK
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

GPG_PRESENT=$(nc -w 1 -U $USER_RUN/.gnupg/S.gpg-agent 2>/dev/null)
if [[ $GPG_PRESENT != OK* ]]; then
    echo "starting gpg-agent..."
    mkdir -p $USER_RUN/gnupg
    rm $USER_RUN/gnupg/S.gpg-agent 2> /dev/null
    socat UNIX-LISTEN:$USER_RUN/gnupg/S.gpg-agent,fork, EXEC:'npiperelay.exe -ei -ep -s -a "C:/Users/NZSmartie/AppData/Roaming/gnupg/S.gpg-agent"',nofork &
    chmod go-rwx $USER_RUN/gnupg -R
fi

source $HOME/.bashrc
