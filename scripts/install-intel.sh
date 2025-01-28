#!/bin/bash

# Function to install Intel XPU drivers and toolkit
install_intel_xpu() {
    echo "Installing Intel XPU Drivers and Toolkit"
    
    # Update the package list
    apt update

    # Install Intel GPU drivers
    echo "Installing Intel GPU drivers"
    apt install -y intel-gpu-tools intel-opencl-icd

    # Install Intel oneAPI Base Toolkit
    echo "Installing Intel oneAPI Base Toolkit"
    wget -qO- https://apt.repos.intel.com/oneapi/gpgkey | gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list
    apt update
    apt install -y intel-basekit

    # Install Intel oneAPI HPC Toolkit
    echo "Installing Intel oneAPI HPC Toolkit"
    apt install -y intel-hpckit

    # Verify the installation
    echo "Verifying Intel XPU installation"
    clinfo
    oneapi-cli version
}

# Function to install PyTorch with Intel support
install_pytorch() {
    echo "Installing PyTorch with Intel support"
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/oneapi
}

# Function to detect Intel XPU
detect_intel_xpu() {
    if lspci | grep -i intel &> /dev/null; then
        echo "Intel XPU detected"
        install_intel_xpu
        install_pytorch
    else
        echo "Intel XPU not detected"
        exit 1
    fi
}

# Main script execution
detect_intel_xpu