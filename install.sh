#!/bin/bash

OS=$(grep '^NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')

if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    if [[ "$OS" == "Arch Linux" ]]; then
        sudo pacman -S git
    elif [[ "$OS" == "Fedora" ]]; then
        sudo dnf install git
    elif [[ "$OS" == "Debian" || "$OS" == "Ubuntu" ]]; then
        sudo apt-get install git
    else
        echo "Unsupported distribution: $OS"
        exit 1
    fi
else
    echo "Git is already installed."
fi

echo "Welcome to the Dolphin PyCore TASing environment install script for Linux"
echo "This will compile Dolphin PyCore on your machine, it might take a long time if you have old hardware"
echo "Detected Linux Distribution: $OS"

if [[ "$OS" == "Arch Linux" ]]; then
    sudo pacman -Syy
    sudo pacman -S pkg-config
    sudo pacman -S make cmake
elif [[ "$OS" == "Fedora" ]]; then
    sudo dnf install pkgconf-pkg-config
    sudo dnf install make cmake
elif [[ "$OS" == "Debian" || "$OS" == "Ubuntu" ]]; then
    sudo apt-get update
    sudo apt-get install pkg-config
    sudo apt-get install build-essentials
else
    echo "Unsupported distribution: $OS"
    exit 1
fi

git clone https://github.com/Blounard/dolphin-pycore
cd dolphin-pycore
git submodule update --init --recursive
mkdir Build && cd Build
env CMAKE_POLICY_VERSION_MINIMUM=3.5 cmake .. -DLINUX_LOCAL_DEV=true
make -j $(nproc)
cp -r ../Data/Sys/ Binaries/
touch Binaries/portable.txt

BINDIR=$(pwd)/Binaries

cd Binaries
git clone https://github.com/Epik95mkw/mkw-scripts.git
cd mkw-scripts
git checkout linux-fix
mv ./scripts/* $BINDIR/user/Load/scripts

echo "PyCore has been built and scripts has been installed. You can find main PyCore GUI binary in $BINDIR/dolphin-emu"
echo "If you are getting errors related to rendering while trying to start a game, then launch the game with the following environment variable: QT_QPA_PLATFORM=xcb"
echo "Thanks to Blounard and all contributors for mantaining PyCore and Epik95 for fixing the latest PyCore scripts to make them compatible with the Linux Python syntax"

