#!/bin/bash

# Function to install PyTorch for CPU
install_pytorch_cpu() {
    echo "Installing PyTorch for CPU"
    pip install torch torchvision torchaudio
}

# Main script execution
install_pytorch_cpu