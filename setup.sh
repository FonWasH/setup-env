#!/bin/bash

G=$'\e[92m'
R=$'\e[91m'
Y=$'\e[33m'
X=$'\e[0m'

ZSHInstall() {
    zsh_install=false

    if ! command -v zsh &>/dev/null; then
        if sudo -l &>/dev/null; then
            sudo apt -y install zsh
            zsh_install=true
            echo "ZSH installed."
        else
            echo "You do not have sudo privileges. Installation cannot proceed."
            return 1
        fi
    else
        echo "ZSH is already installed."
        zsh_install=true
    fi

    if [ "$zsh_install" = true ]; then
        echo "Installing Oh My Zsh..."
        if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh; then
            echo "Oh My Zsh installed."
        else
            echo "Failed to install Oh My Zsh."
            return 1
        fi

        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        echo "ZSH, Oh My Zsh and Powerlevel10k installed."
    else
        echo "ZSH is not installed. Installation cannot proceed."
    fi
}

SSHKey() {
    mail=""
    while [ -z "$mail" ]; do
        read -p "Enter your email address: " mail
    done

    ssh-keygen -t ed25519 -C "$mail"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

    echo "Your public SSH key is:"
    echo ""
    cat ~/.ssh/id_ed25519.pub
}

DotfilesInstall() {
    repo=""
    while [ -z "$repo" ]; do
        read -p "Enter the URL of the dotfiles repository: " repo
    done

    git clone --bare "$repo" "$HOME/.dotfiles"

    echo "Checking out dotfiles..."
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
    if [ $? -ne 0 ]; then
        echo "${R}Warning:${X} Some files could not be checked out. You may need to back up existing dotfiles."
        return 1
    fi

    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config --local status.showUntrackedFiles no
    echo "Dotfiles installed."
}

DevToolsInstall() {
    if sudo -l &>/dev/null; then
        sudo apt -y install build-essential gdb valgrind vim manpages-dev cmake
        echo "Development tools installed."
    else
        echo "You do not have sudo privileges. Installation cannot proceed."
        return 1
    fi
}

Setup() {
    clear
    echo "Welcome, $USER."

    PS3="Enter the number of the option you would like to install (1-5): "
    options=("ZSH, Oh My ZSH and Powerlevel10k" "SSH Key" "Dotfiles" "Dev Tools" "Exit")

    select opt in "${options[@]}"; do
        case $REPLY in
        1)
            ZSHInstall
            ;;
        2)
            SSHKey
            ;;
        3)
            DotfilesInstall
            ;;
        4)
            DevToolsInstall
            ;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
        esac
    done
}

Setup
