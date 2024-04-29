#!/usr/bin/env bash

set -e

colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

installing() {
    check_running_as_root
    detect_os
    detect_and_update_package_manager
    install_package
    install_go
}
check_running_as_root() {
    if [ "$(id -u)" != "0" ]; then
        colorized_echo red "This command must be run as root."
        exit 1
    fi
}
detect_os() {
    # Detect the operating system
    if [ -f /etc/lsb-release ]; then
        OS=$(lsb_release -si)
        elif [ -f /etc/os-release ]; then
        OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
        elif [ -f /etc/redhat-release ]; then
        OS=$(cat /etc/redhat-release | awk '{print $1}')
        elif [ -f /etc/arch-release ]; then
        OS="Arch"
    else
        colorized_echo red "Unsupported operating system"
        exit 1
    fi
}
detect_and_update_package_manager() {
    colorized_echo blue "Updating package manager"
    if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
        PKG_MANAGER="apt-get"
        $PKG_MANAGER update
    else
        colorized_echo red "Unsupported operating system"
        exit 1
    fi
}
install_package () {
    if [ -z $PKG_MANAGER ]; then
        detect_and_update_package_manager
    fi
    colorized_echo blue "Installing Package"
    if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
        $PKG_MANAGER -y install build-essential \
        curl \
        make \
        git \
        wget \
        qrencode \
        python3 \
        python3-pip
    else
        colorized_echo red "Unsupported operating system"
        exit 1
    fi
}


install_go() {
    mkdir -p /opt/go
    cd /opt/go
    curl -O https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xvzf go1.22.0.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
    source ~/.profile
    if go version >/dev/null 2>&1; then
        echo "Golang installed"
    else
        colorized_echo red "golang not found"
        exit 1
    fi
}

case "$1" in
    install)
    shift; installing "$@";;
    *)
    usage;;
esac
