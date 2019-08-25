#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
SCRIPTPATH=$(dirname $SCRIPT)

if [ ! -d "$HOME/.local/bin" ] ; then
    echo "creating $HOME/.local/bin"
    mkdir -p "$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    if [ ! -f "$HOME/.local/bin/detectcontainer.sh" ] ; then
        echo "copying $SCRIPTPATH/detectcontainer.sh to $HOME/.local/bin"
        cp "$SCRIPTPATH/detectcontainer.sh" "$HOME/.local/bin/"
    fi
fi

if [ -f "$HOME/.bashrc" ] ; then
    grep detectcontainer "$HOME/.bashrc" >/dev/null
    if [ "$?" -ne 0 ] ; then
        echo "creating backup  of .bashrc"
        cp -a "$HOME/.bashrc" "$HOME/.bashrc_$(date)"
        sed -i -E 's;(PS1.*?)(\\u@\\h.*?);\1$(/bin/bash $HOME/.local/bin/detectcontainer.sh)\2;g' "$HOME/.bashrc"        
        sed -i -E 's;(PROMPT_COMMAND.*?)(\$\{USER\}@\$\{HOSTNAME\}.*?);\1$(/bin/bash $HOME/.local/bin/detectcontainer.sh)\2;g' "$HOME/.bashrc"
    fi
fi