#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
WHITE='\033[0;37m'
CYAN='\033[0;36m'
RED='\033[0;31m'

# Função para baixar arquivos
download() {
    wget -q --show-progress -O "$2" "$1"
}

# Função para instalar o Cloudflared
install_cloudflared() { 
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
    fi
}

# Função para iniciar o Cloudflared
start_cloudflared() { 
    rm .cld.log > /dev/null 2>&1 &
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
    sleep 1
    echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

    if command -v termux-chroot &> /dev/null; then
        sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
    fi

    sleep 8
    if [[ -e ".server/.cld.log" ]]; then
        cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log")
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Conecte-se ao servidor Minecraft usando o seguinte link: ${WHITE}$cldflr_url${CYAN}"
    else
        echo "Log file not found. Unable to retrieve Cloudflared URL."
    fi
}

# Instalação do Java
install_java() {
    echo "Installing Java..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk openjdk-17-jre libc6-x32 libc6-i386
}

# Função principal
main() {
    HOST="localhost"
    PORT="25565" # Porta do seu servidor

    # Instala o Cloudflared
    install_cloudflared

    # Instala o Java
    install_java

    # Inicia o Cloudflared
    start_cloudflared

    # Inicia o servidor Minecraft
    echo "Starting Minecraft server..."
    java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

    echo "Minecraft server started with Cloudflared IP."
}

# Executa a função principal
main
