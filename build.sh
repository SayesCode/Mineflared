#!/bin/bash

# Version = "V2"

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
        
        if [[ -e ".server/cloudflared" ]]; then
            echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Cloudflared installed successfully."
        else
            echo -e "${RED}[${WHITE}--${RED}]${CYAN} Failed to move Cloudflared to .server directory."
        fi
    fi
}

install_java() {
    echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Detecting system architecture and distribution..."${WHITE}
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        ARCH_TYPE="x64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        ARCH_TYPE="aarch64"
    else
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Unsupported architecture: $ARCH" 
        exit 1
    fi

    # Check distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Unsupported distribution or /etc/os-release not found." 
        exit 1
    fi

    # Set download URL based on architecture and distribution
    if [[ "$ARCH_TYPE" == "x64" ]]; then
        if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
            URL="https://download.oracle.com/java/21/archive/jdk-21.0.3_linux-x64_bin.deb"
            PACKAGE_TYPE="deb"
        elif [[ "$DISTRO" == "centos" || "$DISTRO" == "fedora" || "$DISTRO" == "rhel" ]]; then
            URL="https://download.oracle.com/java/21/archive/jdk-21.0.3_linux-x64_bin.rpm"
            PACKAGE_TYPE="rpm"
        else
            echo -e "${RED}[${WHITE}--${RED}]${CYAN} Unsupported distribution for x64: $DISTRO"
            exit 1
        fi
    elif [[ "$ARCH_TYPE" == "aarch64" ]]; then
        if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
            URL="https://download.oracle.com/java/21/archive/jdk-21.0.3_linux-aarch64_bin.tar.gz"
            PACKAGE_TYPE="tar.gz"
        elif [[ "$DISTRO" == "centos" || "$DISTRO" == "fedora" || "$DISTRO" == "rhel" ]]; then
            URL="https://download.oracle.com/java/21/archive/jdk-21.0.3_linux-aarch64_bin.rpm"
            PACKAGE_TYPE="rpm"
        else
            echo -e "${RED}[${WHITE}--${RED}]${CYAN} Unsupported distribution for aarch64: $DISTRO"
            exit 1
        fi
    fi

    # Download JDK
    echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Downloading JDK from $URL..."${WHITE}
    download "$URL" "jdk-download"

    # Install JDK
    if [[ "$PACKAGE_TYPE" == "deb" ]]; then
        echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing .deb package..."${WHITE}
        sudo dpkg -i jdk-download
    elif [[ "$PACKAGE_TYPE" == "rpm" ]]; then
        echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing .rpm package..."${WHITE}
        sudo rpm -ivh jdk-download
    elif [[ "$PACKAGE_TYPE" == "tar.gz" ]]; then
        echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Extracting .tar.gz file..."${WHITE}
        tar -xzf jdk-download
        echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Moving to /opt..."${WHITE}
        sudo mv jdk-21.0.3 /opt/
        echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Setting up environment variables..."${WHITE}
        echo "export JAVA_HOME=/opt/jdk-21.0.3" | sudo tee -a /etc/profile.d/jdk.sh
        echo "export PATH=\$PATH:\$JAVA_HOME/bin" | sudo tee -a /etc/profile.d/jdk.sh
        source /etc/profile.d/jdk.sh
    fi

    # Clean up
    echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Cleaning up..."${WHITE}
    rm -f jdk-download 

    # Verify installation
    echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Verifying installation..."${WHITE}
    java -version
    echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Java installed successfully!"
}

install_make() {
    sudo apt install build-essential -y
    sudo apt install gcc -y
    sudo apt install make -y
}

sudo apt install python3
sudo apt install python3-pip
sudo apt install curl
install_make
install_java
install_cloudflared

bash ./start.sh
