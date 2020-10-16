#!/bin/bash

install_path="$HOME/Desktop/git"

function err() {
    echo "[-] $1"
}

function log() {
    echo "[*] $1"
}

function wrn() {
    echo "[!] $1"
}

function install_desktop_app() {
    if ! [[ "$OSTYPE" == "linux-gnu" ]]
    then
        return
    fi
    cd ~/.local/share/applications || { err "failed to cd into ~/.local/share/applications"; exit 1; }
    if [ ! -f ZillyWoods.desktop ]
    then
        log "installing ZillyWoods.desktop"
        curl https://raw.githubusercontent.com/ZillyWoods/ZillyWoods-scripts/master/ZillyWoods.desktop > ZillyWoods_tmp.txt
        path_sed="$(echo "$install_path/ZillyWoods" | sed 's/\//\\\//g')"
        sed "s/ZILLYWOODS_PATH/$path_sed/g" ZillyWoods_tmp.txt > ZillyWoods.desktop
        rm ZillyWoods_tmp.txt
    fi
}

function install_start_helper() {
    local tmp_dl
    if [ -f /usr/local/bin/zilly ]
    then
        if ! grep -q 'https://github.com/ZillyWoods/ZillyWoods-scripts/blob/master/start.sh' /usr/local/bin/zilly
        then
            err "Error: could not update non official start script"
            err "       please update manually:"
            err "       /usr/local/bin/zilly"
            return
        fi
    fi
    tmp_dl="$(mktemp /tmp/zilly_start.sh.XXXXXXXX)"
    wget -O "$tmp_dl" https://raw.githubusercontent.com/ZillyWoods/ZillyWoods-scripts/master/start.sh
    sudo mv "$tmp_dl" /usr/local/bin/zilly
    sudo chmod +x /usr/local/bin/zilly
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
    [ -x "$(which "$1")" ]
}

function build_desktop() {
    cd "$install_path" || { err "failed to cd"; exit 1; }
    if [ ! -d ZillyWoods ]
    then
        git clone --recursive git@github.com:ZillyWoods/ZillyWoods
    fi
    cd ZillyWoods || exit 1
    mkdir -p build
    cd build || exit 1
    cmake ..
    make
}

function build_tmp() {
    cd /tmp || exit 1
    repo=ZillyWoods_$(date +%s)
    git clone --recursive https://github.com/ZillyWoods/ZillyWoods "$repo"
    cd "$repo" || exit 1
    mkdir -p build
    cd build || exit 1
    cmake ..
    make
    sudo cp zillywoods "$install_path/"
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
    build_desktop
}

if [ ! -d "$install_path" ]
then
    err "Install directory not found '$install_path'"
    log "do you want to create it? [y/N]"
    read -r -n 1 yn
    echo ""
    if [[ ! "$yn" =~ [yY] ]]
    then
        log "aborted installation."
        exit 1
    fi
    mkdir -p "$install_path"
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

install_start_helper
install_from_source
install_desktop_app

log "done."

