#!/bin/bash

# Version = "V2"

# Terminal colors
GREEN='\033[0;32m'
WHITE='\033[0;37m'
CYAN='\033[0;36m'
RED='\033[0;31m'

# Function to ensure venv is installed
install_venv_if_needed() {
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
        echo -e "${CYAN}Installing python3-venv package..."
        apt update
        apt install python3-venv -y
    fi
}

# Function to create and activate virtual environment
setup_virtualenv() {
    # Install venv if necessary
    install_venv_if_needed

    # Create a virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo -e "${CYAN}Creating Python virtual environment..."
        python3 -m venv venv
    fi

    # Activate the virtual environment
    echo -e "${CYAN}Activating virtual environment..."
    source venv/bin/activate
}

# Function to start the HTTP server
start_http_server() {
    apt install nodejs -y
    apt install npm -y
    npm install > /dev/null
    npm start > /dev/null &
    
    # Install required Python packages inside the virtual environment
    pip3 install -r requirements.txt
    python3 utils/bot.py &
}

# Function to start Cloudflared without authentication
start_cloudflared() { 
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

    # Launch Cloudflared for redirection
    ./.server/cloudflared tunnel --url http://localhost:25565 --logfile .server/.cld.log > /dev/null 2>&1 &

    sleep 8
    cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log" | head -n 1)
    
    if [ -z "$cldflr_url" ]; then
        echo -e "${RED}[${WHITE}--${RED}]${CYAN} Log file not found. Unable to retrieve Cloudflared URL."
    else
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Connect to the Minecraft server using the following link: ${WHITE}$cldflr_url"
        
        # Send the message in markdown format to Discord
        send_markdown_to_discord "$cldflr_url"
    fi
}

# Function to send the content of a Markdown file to Discord via the /send endpoint
send_markdown_to_discord() {
    local cldflr_url=$1
    message="Connect to the Minecraft server using the following link: \`$cldflr_url:25565\`"
    
    # Send a POST request to the /send endpoint with the message in markdown format
    curl -X POST http://localhost:8080/send \
        -H "Content-Type: application/json" \
        -d "{\"message\": \"$message\"}"
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

    # Set up the virtual environment
    setup_virtualenv

    # Start the HTTP server
    start_http_server

    # Start Cloudflared
    start_cloudflared

    make

    # Start Mineflared-Firewall
    ./minefirewall &

    make test

    # Start the Minecraft server
    echo "Starting Minecraft server..."
    java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

    echo "Minecraft server started with Cloudflared IP."
}

# Execute the main function
main
