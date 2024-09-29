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

# Função para iniciar o servidor HTTP
start_http_server() {
    echo "Iniciando servidor HTTP para index.html na porta 8080..."
    python3 -m http.server 8080 --directory "$(pwd)" > /dev/null 2>&1 &
}

# Função para iniciar o Cloudflared sem autenticação
start_cloudflared() { 
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

    # Lança o Cloudflared para o redirecionamento
    ./.server/cloudflared tunnel --url http://localhost:8080 --logfile .server/.cld.log > /dev/null 2>&1 &
    
    sleep 8
    cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log" | head -n 1)
    
    if [ -z "$cldflr_url" ]; then
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Log file not found. Unable to retrieve Cloudflared URL."
    else
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Conecte-se ao servidor Minecraft usando o seguinte link: ${WHITE}$cldflr_url:${RED}25565"
    fi
}

# Instalação do Java
install_java() {
    echo "Detecting system architecture..."
    ARCH=$(uname -m)

    if [[ "$ARCH" == "x86_64" ]]; then
        echo "Installing Java 21 for x86_64..."
        URL="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        echo "Installing Java 21 for aarch64..."
        URL="https://download.oracle.com/java/21/latest/jdk-21_linux-aarch64_bin.tar.gz"
    else
        echo "Unsupported architecture: $ARCH"
        return 1
    fi

    echo "Downloading Java from $URL..."
    wget $URL -O jdk-21.tar.gz

    echo "Extracting files..."
    tar -xzf jdk-21.tar.gz

    echo "Installing Java..."
    sudo mv jdk-21 /usr/local/
    sudo update-alternatives --install /usr/bin/java java /usr/local/jdk-21/bin/java 1
    sudo update-alternatives --install /usr/bin/javac javac /usr/local/jdk-21/bin/javac 1

    echo "Java installed successfully!"
    java -version
}


# Função principal
main() {
    HOST="localhost"
    PORT="25565" # Altere para a porta do seu servidor

    # Instala o Cloudflared
    install_cloudflared

    # Verifica a instalação do Cloudflared
    if [[ ! -e ".server/cloudflared" ]]; then
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Cloudflared not installed correctly. Exiting."
        exit 1
    fi

    # Instala o Java
    install_java
    
    # Inicia o servidor HTTP
    start_http_server

    # Inicia o Cloudflared
    start_cloudflared

    # Inicia o servidor Minecraft
    echo "Starting Minecraft server..."
    java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

    echo "Minecraft server started with Cloudflared IP."
}

# Executa a função principal
main
