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
			clear
			echo "ZSH installed."
			zsh_install=true
		else
			clear
			echo "You do not have sudo privileges. Installation cannot proceed."
			return 1
		fi
	else
		clear
		echo "ZSH is already installed."
		zsh_install=true
	fi
	if $zsh_install; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
		clear
		echo "ZSH, Oh My ZSH and Powerlevel10k installed."
	else
		clear
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
	clear
	echo "Your public key is:"
	echo ""
	cat ~/.ssh/id_ed25519.pub
}

DotfilesInstall() {
	repo=""
	while [ -z "$repo" ]; do
		read -p "Enter the URL of the dotfiles repository: " repo
	done
	git clone --bare $repo ~/dotfiles
	setopt -s glob_dots
	mv ~/dotfiles/* ~/
	rm -rf ~/dotfiles
	clear
	echo "Dotfiles installed."
}

DevToolsInstall() {
	if sudo -l &>/dev/null; then
		sudo apt -y install build-essential gdb valgrind vim manpages-dev cmake
		clear
		echo "Tools installed."
	else
		clear
		echo "You do not have sudo privileges. Installation cannot proceed."
		return 1
	fi
}

Setup() {
	clear
	echo "Welcome $USER."
	while true; do
		echo ""
		echo "What would you like to install?"
		echo ""
		echo "	${Y}1. ${G}ZSH, Oh My ZSH and Powerlevel10k${X}"
		echo "	${Y}2. ${G}SSH Key${X}"
		echo "	${Y}3. ${G}Dotfiles${X}"
		echo "	${Y}4. ${G}Dev Tools${X}"
		echo "	${Y}5. ${R}Exit${X}"
		echo ""
		read -p "Enter the number of the option you would like to install (${Y}1${X}/${Y}2${X}/${Y}3${X}/${Y}4${X}/${Y}5${X}): " option
		case $option in
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
			clear
			echo "Exiting..."
			exit 0
			;;
		*)
			clear
			echo "Invalid option. Please try again."
			;;
		esac
	done
}

Setup
