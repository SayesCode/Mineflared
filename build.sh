#!/bin/bash

# Verison = "V1"

# Terminal colors
GREEN='\033[0;32m'
WHITE='\033[0;37m'
CYAN='\033[0;36m'
RED='\033[0;31m'

# Function to download files
download() {
    wget -q --show-progress -O "$2" "$1"
}

check_arch() {
arch=$(uname -m)
  if [[ "$arch" == *"Android"* ]]; then
    bash termux/termux.sh
  fi
}

# Function to install Cloudflared
install_cloudflared() { 
    mkdir -p .server

    if [[ -e ".server/cloudflared" ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
    else
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."${WHITE}
        arch=$(uname -m)
        if [[ "$arch" == *'arm'* || "$arch" == *'Android'* ]]; then
            download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'
        elif [[ "$arch" == *'aarch64'* ]]; then
            download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
        elif [[ "$arch" == *'x86_64'* ]]; then
            download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
        else
            download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
        fi
        
        chmod +x ./cloudflared
        mv ./cloudflared .server/cloudflared
        
        # Verifica se o arquivo foi movido corretamente
        if [[ -e ".server/cloudflared" ]]; then
            echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Cloudflared installed successfully."
        else
            echo -e "${RED}[${WHITE}--${RED}]${CYAN} Failed to move Cloudflared to .server directory."
        fi
    fi
}

install_java() {
    echo "Installing Java 17..."
    sudo apt remove openjdk-11-* --purge
    sudo apt remove openjdk-8-* --purge
    sudo apt install openjdk-17-jdk openjdk-17-jre
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    source ~/.bashrc
    
    echo "Java installed successfully!"
    java -version
}

install_make() {
sudo apt install build-essential
sudo apt install gcc
sudo apt install make
make
}

install_make
install_java
install_cloudflared

clear
bash ./start.sh
