#!/bin/bash

install_path=/usr/games

function err() {
    echo "[-] $1"
}

function log() {
    echo "[*] $1"
}

function wrn() {
    echo "[!] $1"
}

function install_brew() {
    command -v brew >/dev/null 2>&1 || {
        wrn "to install dependencys you need brew."
        log "do you want to install brew? [y/N]"
        read -r -n 1 yn
        echo ""
        if [[ "$yn" =~ [yY] ]]
        then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
    }
}

has_package_manager() {
    [ -x "$(which $1)" ]
}

function install_from_source() {
    if [[ "$OSTYPE" == "linux-gnu" ]]
    then
        if has_package_manager apt;
        then
            sudo apt install build-essential cmake git libfreetype6-dev libsdl2-dev libpnglite-dev libwavpack-dev python3
        elif has_package_manager dnf;
        then
            sudo dnf install @development-tools cmake gcc-c++ git freetype-devel mesa-libGLU-devel pnglite-devel python3 SDL2-devel wavpack-devel
        elif has_package_manager pacman;
        then
            sudo pacman -S --needed base-devel cmake freetype2 git glu python sdl2 wavpack
        else
            err "Your package manager is not supported."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]
    then
        install_brew
        brew install cmake freetype sdl2
    else
        err "Compiling source on your os is not supported."
        exit 1
    fi
    cd /tmp
    repo=ZillyWoods_$(date +%s)
    git clone --recursive https://github.com/ZillyWoods/ZillyWoods $repo
    cd $repo
    mkdir build
    cd build
    cmake ..
    make
    sudo cp zillywoods "$install_path/"
}

if [ ! -d "$install_path" ]
then
    err "Install directory not found '$install_path'"
    exit 1
fi

if [ -f "$install_path/zillywoods" ]
then
    wrn "ZillyWoods is installed already!"
    log "do you want to update it? [y/N]"
    read -r -n 1 yn
    echo ""
    if [[ ! "$yn" =~ [yY] ]]
    then
        log "aborted installation."
        exit
    fi
fi

install_from_source

log "done."
