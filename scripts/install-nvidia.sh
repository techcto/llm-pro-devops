#!/bin/bash

# Function to install Nvidia drivers
install_nvidia_drivers() {
    echo "Installing Nvidia Drivers"
    apt autoremove nvidia* --purge -y
    apt update
    apt install ubuntu-drivers-common -y

    ubuntu-drivers devices
    apt install nvidia-driver-560 -y --quiet

    nvidia-smi
    lspci | grep -i nvidia
}

# Function to install CUDA
install_cuda() {
    # Get the CUDA version from nvidia-smi
    CUDA_VERSION=$(nvidia-smi | grep -Po 'CUDA Version: \K[0-9]+.[0-9]+')

    # Install the appropriate CUDA toolkit
    case $CUDA_VERSION in
        11.0) CUDA_PKG="cuda-11-0" ;;
        11.1) CUDA_PKG="cuda-11-1" ;;
        11.2) CUDA_PKG="cuda-11-2" ;;
        11.3) CUDA_PKG="cuda-11-3" ;;
        12.0) CUDA_PKG="cuda-12-0" ;;
        12.1) CUDA_PKG="cuda-12-1" ;;
        *) 
            echo "Unsupported CUDA version: $CUDA_VERSION"
            exit 1
            ;;
    esac

    echo "Installing CUDA Toolkit version $CUDA_VERSION"
    apt install $CUDA_PKG -y
    apt install nvidia-cuda-toolkit -y

    # Verify the CUDA installation
    nvcc --version
}

# Function to install PyTorch with CUDA support
install_pytorch() {
    echo "Installing PyTorch with CUDA support"
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$CUDA_VERSION
}

# Main script execution
install_nvidia_drivers
install_cuda
install_pytorch