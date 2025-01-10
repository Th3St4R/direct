#!/bin/bash

install_jq() {
    if ! command -v jq &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo "jq is not installed. Installing..."
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo "Error: Unsupported package manager. Please install jq manually."
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

install_curl() {
    if ! command -v curl &> /dev/null; then
        echo "curl is not installed. Installing..."
        sleep 1
        sudo apt-get update
        sudo apt-get install -y curl
    fi
}

loader(){
    install_jq
    install_curl
    SERVER_IP=$(hostname -I | awk '{print $1}')
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
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
    cd website-templates-master || { echo "Failed to change directory to website-templates-master"; exit 1; }
    rm -rf assets
    rm ".gitattributes" "README.md" "_config.yml"
    
    randomTemplate=$(find . -maxdepth 1 -type d | shuf -n 1)
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
    echo "------- Web Server ------- "
    echo "|"
    echo "|  22 - Install Nginx + Fake-WebSite Template [HTML]"
    echo "|"
    echo ""
    read -p "Please choose an option: " choice
    case $choice in
        22)
            setupFakeWebSite
        ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
        ;;
    esac
}

loader
menu
