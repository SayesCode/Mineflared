#!/bin/bash

# Function to install apt based on the distro
install_apt() {
    case $(lsb_release -si) in
        Ubuntu|Debian)
            echo "Updating package list..."
            sudo apt update
            ;;
        Fedora|RHEL|CentOS)
            echo "Installing apt via DNF..."
            sudo dnf install apt -y
            ;;
        Arch)
            echo "Installing apt via pacman..."
            sudo pacman -S apt -y
            ;;
        *)
            echo "Unsupported distribution. Please install apt manually."
            exit 1
            ;;
    esac
}

# Check if apt is available
if ! command -v apt &> /dev/null; then
    echo "apt not found. Installing..."
    install_apt
fi

# Update package list and install Java
echo "Installing Java..."
sudo apt update
sudo apt install -y openjdk-17-jdk
sudo apt install -y openjdk-17-jre
sudo apt install -y libc6-x32 libc6-i386
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb
sudo dpkg -i jdk-17_linux-x64_bin.deb
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-17/bin/java 0;
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-17/bin/javac 0;
sudo update-alternatives --set java /usr/lib/jvm/jdk-17/bin/java;
sudo update-alternatives --set javac /usr/lib/jvm/jdk-17/bin/javac
java -version && javac -version


# Download Cloudflared
echo "Downloading Cloudflared..."
sudo apt install cloudflared

# Start Cloudflared
nohup ./cloudflared tunnel run &

# Wait for Cloudflared to initialize
echo "Waiting for Cloudflared to start..."
sleep 10

# Get the IP address of Cloudflared
echo "Checking IP address..."
cloudflared tunnel list


# Run Minecraft server
java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

echo "Minecraft server started with Cloudflared IP."

