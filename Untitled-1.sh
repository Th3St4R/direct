#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m'

install_jq() {
    if ! command -v jq &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

setupFakeWebSite(){
    sudo apt-get update
    sudo apt-get install unzip -y

    if ! command -v nginx &> /dev/null; then
        echo "The Nginx software is not installed; the installation process has started."
        if sudo apt-get install -y nginx; then
            echo "Nginx was successfully installed."
        else
            echo "An error occurred during the Nginx installation process." >&2
            exit 1
        fi
    else
        echo "The Nginx software was already installed."
    fi

    cd /root || { echo "Failed to change directory to /root"; exit 1; }

    if [[ -d "website-templates-master" ]]; then
        echo "Removing existing 'website-templates-master' directory..."
        rm -rf website-templates-master
    fi

    wget https://github.com/learning-zone/website-templates/archive/refs/heads/master.zip
    unzip master.zip
    rm master.zip
    cd website-templates-master || { echo "Failed to change directory to randomfakehtml-master"; exit 1; }
    rm -rf assets
    rm ".gitattributes" "README.md" "_config.yml"

    randomTemplate=$(a=(*); echo ${a[$((RANDOM % ${#a[@]}))]} 2>&1)
    if [[ -n "$randomTemplate" ]]; then
        echo "Random template name: ${randomTemplate}"
    else
        echo "No directories found to choose from."
        exit 1
    fi

    if [[ -d "${randomTemplate}" && -d "/var/www/html/" ]]; then
        sudo rm -rf /var/www/html/*
        sudo cp -a "${randomTemplate}/." /var/www/html/
        echo "Template extracted successfully!"
    else
        echo "Extraction error!"
    fi
}

menu(){
    clear
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo "|   ##     ####    ####    ####   ####   ######    ##     ##  ##   ######        ##  ##   #####    ####        |"
    echo "|  ####   ##  ##  ##  ##    ##   ##  ##    ##     ####    ### ##     ##          ##  ##   ##  ##  ##  ##       |"
    echo "| ##  ##  ##      ##        ##   ##        ##    ##  ##   ######     ##          ##  ##   ##  ##  ##           |"
    echo "| ######   ####    ####     ##    ####     ##    ######   ######     ##   #####  ##  ##   #####    ####        |"
    echo "| ##  ##      ##      ##    ##       ##    ##    ##  ##   ## ###     ##          ##  ##   ##          ##       |"
    echo "| ##  ##  ##  ##  ##  ##    ##   ##  ##    ##    ##  ##   ##  ##     ##           ####    ##      ##  ## (2.5) |"
    echo "| ##  ##   ####    ####    ####   ####     ##    ##  ##   ##  ##     ##            ##     ##       ####        |"
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "|  Telegram Channel : ${YELLOW}@DVHOST_CLOUD ${NC} |  YouTube : ${RED}youtube.com/@dvhost_cloud${NC}   |  Version : ${GREEN} 2.5${NC} "
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "${GREEN}|Server Location:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}|Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}|Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------------------------------------------------------+"
    echo -e "${YELLOW}"
    echo -e "  ------- ${GREEN}Web Server${YELLOW} ------- "
    echo "|"
    echo -e "|  22 - Install Nginx + Fake-WebSite Template [HTML]"
    echo "|"
    echo -e " ------- ${GREEN}Exit${YELLOW} ------- "
    echo "|"
    echo -e "|  0  - Exit"
    echo ""
    echo -e "${NC}+-------------------------------------------------------------------------------------------------------------+${NC}"

    read -p "Please choose an option: " choice

    case $choice in
        22)
            setupFakeWebSite
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
}

loader
menu
