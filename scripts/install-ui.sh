#!/bin/bash

# Script to initialize UI

# Function to install packages using apt-get
install_apt_packages() {
    sudo apt-get update
    sudo apt-get install nginx python3-certbot-nginx -y
    
    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

    # Load nvm into the current shell session
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install and use a compatible version of Node.js
    nvm install 22.9.0
    nvm use 22.9.0

    # Update npm to the latest version
    npm install -g npm@latest

    # Verify the installation
    node -v
    npm -v
}

# Function to provide instructions for installing packages using conda-forge
install_conda_packages() {
    echo "For non-Ubuntu systems, please install the following packages using conda-forge:"
    echo "conda install -c conda-forge npm nginx python-certbot-nginx"
}

# Function to detect operating system and install packages
install_packages() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "Ubuntu detected. Installing packages using apt-get..."
            install_apt_packages
        else
            echo "Non-Ubuntu system detected. Providing conda-forge installation instructions..."
            install_conda_packages
        fi
    else
        echo "OS detection failed. Providing conda-forge installation instructions..."
        install_conda_packages
    fi
}

# Install necessary packages
install_packages

# Clone the repository
git clone https://github.com/techcto/nextjs-vllm-ui.git ./submodules/nextjs-vllm-ui

# Change directory to the cloned repository
cd submodules/nextjs-vllm-ui

# Copy example environment file to .env
cp .example.env .env

# Install npm dependencies
npm install

# Build
npm run build