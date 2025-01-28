#!/bin/bash

# Script to install llamacpp from source

# Function to install packages using apt-get
install_apt_packages() {
    sudo apt-get update
    sudo apt-get install -y libssl-dev libcurl4-openssl-dev cmake build-essential ccache libopenblas-dev
}

# Function to install packages using conda-forge
install_conda_packages() {
    conda install -y -c conda-forge libssl libcurl cmake ccache openblas
}

# Function to detect operating system and install packages
install_packages() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "Ubuntu detected. Installing packages using apt-get..."
            install_apt_packages
            echo "Creating llamacpp user and adding to sudo group..."
            sudo adduser --disabled-password --gecos "" llamacpp
            sudo usermod -aG sudo llamacpp
        else
            echo "Non-Ubuntu system detected. Installing packages using conda-forge..."
            install_conda_packages
        fi
    else
        echo "OS detection failed. Installing packages using conda-forge..."
        install_conda_packages
    fi
}

# Function to install and enable the service
install_service() {
    echo "Installing llamacpp service..."
    sudo cp -f ./bin/llamacppd.service /etc/systemd/system/llamacppd.service
    sudo systemctl enable llamacppd
    sudo systemctl start llamacppd
}

# Function to check for NVIDIA GPU
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU detected."
        export DGGML_CUDA=True
        return 0
    else
        export DGGML_CUDA=False
        return 1
    fi
}

# Function to check for AMD GPU
check_amd_gpu() {
    if lspci | grep -i 'vga' | grep -i 'amd' &> /dev/null; then
        echo "AMD GPU detected."
        return 0
    else
        return 1
    fi
}

# Function to check for Intel XPU
check_intel_xpu() {
    if lspci | grep -i 'vga' | grep -i 'intel' &> /dev/null; then
        echo "Intel XPU detected."
        return 0
    else
        return 1
    fi
}

# Function to set the appropriate environment file based on detected hardware
set_env_file() {
    env_dir="../../scripts/bin"
    if check_nvidia_gpu || check_amd_gpu; then
        echo "Setting environment file for GPU."
        sudo cp -f $env_dir/llamacpp.gpu.env /etc/llamacpp/llamacpp.env
    elif check_intel_xpu; then
        echo "Setting environment file for XPU."
        sudo cp -f $env_dir/llamacpp.xpu.env /etc/llamacpp/llamacpp.env
    else
        echo "Setting environment file for CPU."
        sudo cp -f $env_dir/llamacpp.cpu.env /etc/llamacpp/llamacpp.env
    fi
}

echo "Installing llamacpp from source..."
git clone https://github.com/ggerganov/llama.cpp.git ./submodules/llamacpp
cd ./submodules/llamacpp

# Install necessary packages
install_packages

# Run cmake with the specified options
cmake -B build -DBUILD_SHARED_LIBS=OFF -DLLAMA_CURL=ON -DGGML_CUDA=${DGGML_CUDA} -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release -j 8

# Copy binaries to /usr/bin
sudo cp -f ./build/bin/llama-cli /usr/bin/llama-cli
sudo cp -f ./build/bin/llama-server /usr/bin/llama-server
sudo cp -f ./build/bin/llama-quantize /usr/bin/llama-quantize

# Create directory and set permissions
sudo mkdir -p /etc/llamacpp && sudo chown -R llamacpp:llamacpp /etc/llamacpp

# Set the appropriate environment file based on detected hardware
set_env_file

# Source the environment file
. /etc/llamacpp/llamacpp.env

# Set permissions for the binaries and configuration directory
sudo chown -Rf llamacpp:llamacpp /etc/llamacpp /usr/bin/llama-server /usr/bin/llama-cli /usr/bin/llama-quantize

# Function to run llama-cli with specified model
run_llama_cli() {
    local model=$1
    llama-cli -m "$model" --prompt "Once upon a time" -n 6
}

# Parse arguments for model
while getopts ":m:" option; do
    case $option in
        m)
            model=$OPTARG
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done

# Run llama-cli if model is specified
if [ -n "$model" ]; then
    run_llama_cli "$model"
fi