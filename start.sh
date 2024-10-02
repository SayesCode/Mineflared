#!/bin/bash

# Verison = "V1"

# Terminal colors
GREEN='\033[0;32m'
WHITE='\033[0;37m'
CYAN='\033[0;36m'
RED='\033[0;31m'

# Function to start the HTTP server
start_http_server() {
    sudo apt install nodejs
    sudo apt install npm
    npm install > /dev/null
    npm start > /dev/null &
    echo "Starting HTTP server for index.html on port 8080..."
    python3 -m http.server 80 --directory static > /dev/null 2>&1 &
}

# Function to start Cloudflared without authentication
start_cloudflared() { 
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

    # Launch Cloudflared for redirection
    ./.server/cloudflared tunnel --url http://127.0.0.1/ --logfile .server/.cld.log > /dev/null 2>&1 &
    
    sleep 8
    cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log" | head -n 1)
    
    if [ -z "$cldflr_url" ]; then
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Log file not found. Unable to retrieve Cloudflared URL."
    else
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Connect to the Minecraft server using the following link: ${WHITE}$cldflr_url:${RED}25565"
    fi
}



# Main function
main() {
    HOST="localhost"
    PORT="25565" # Change to your server's port

    # Check Cloudflared installation
    if [[ ! -e ".server/cloudflared" ]]; then
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Cloudflared not installed correctly. Exiting."
        exit 1
    fi
    
    # Start the HTTP server
    start_http_server

    # Start Cloudflared
    start_cloudflared

    # Start the Minecraft server
    echo "Starting Minecraft server..."
    java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

    echo "Minecraft server started with Cloudflared IP."
}

# Execute the main function
main
