#!/bin/bash
set -o nounset

OPTIONS=(apt ohmyzsh tpm dotfile)

install_dotfile(){
    local dotfile="
    .bash_aliases
    .tmux.conf
    .vimrc
    .zshrc
    "
    for i in $dotfile
    do
        \cp -fr $i ~/
    done

    mkdir -p ~/.pip
    cp .pip/pip.conf ~/.pip

}

install_ohmyzsh(){
     export RUNZSH=no
     sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_tpm(){
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    tmux new -d -s delete-me && tmux run-shell ~/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux source-file ~/.tmux.conf && tmux kill-session -t delete-me
}

install_apt(){
    sudo apt-get update && sudo apt-get install -y docker.io tmux zsh
    sudo usermod --shell $(grep /zsh$ /etc/shells | tail -1) $(whoami)
    # docker conf
    sudo usermod -aG docker $(whoami)
    sudo systemctl start docker
    sudo systemctl enable docker

    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    git config --global core.editor "vim"
    git config merge.tool vimdiff
    git config merge.conflictstyle diff3
    git config mergetool.prompt false
}

usage(){
cat <<EOF
Usage: $0 OPTIONS
          OPTIONS: all ${OPTIONS[@]}
EOF
}

main(){
    if [ $# -ne 1 ]; then
        echo $#
        usage
        exit 1
    fi

    if [[ " ${OPTIONS[@]} " =~ " $1 " ]]; then
        echo "install $1 ..."
        install_$1
    else
        for o in ${OPTIONS[@]}
        do
            echo "install $o ..."
            install_$o
        done
    fi
}

main $@
