# Start of llm-cmd.sh
#!/bin/bash

# Function to initialize GPU
gpuinit() {
    ./scripts/install-nvidia.sh
}

# Function to initialize XPU
xpuinit() {
    ./scripts/install-intel.sh
}

# Function to initialize CPU
cpuinit() {
    ./scripts/install-cpu.sh
}

# Function to install llamacpp from source
llamacppinit() {
    ./scripts/install-llamacpp.sh "$@"
}

# Function to initialize UI
uiinit() {
    ./scripts/install-ui.sh
}

# Function to start the UI server
start_ui_server() {
    cd ./submodules/nextjs-vllm-ui
    npm run start
}

# Function to detect system type
detect_system_type() {
    if command -v nvidia-smi &> /dev/null; then
        echo "GPU detected"
        gpuinit
    elif command -v xpuinfo &> /dev/null; then
        echo "XPU detected"
        xpuinit
    else
        echo "CPU detected"
        cpuinit
    fi
}

# Function to setup and activate Python virtual environment
VENV_DIR=~/llmpro

setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        echo "Virtual environment created at $VENV_DIR"
    fi
    source "$VENV_DIR/bin/activate"
    python3 -m pip install --upgrade pip
}

# Function to read or initialize configuration
initialize_config() {
    CONFIG_FILE=llmconfig
    if [ ! -f "$CONFIG_FILE" ]; then
        setup_venv
        detect_system_type
        llamacppinit
        uiinit
        touch "$CONFIG_FILE"
        echo "envs_initialized=true" > "$CONFIG_FILE"
    else
        source "$VENV_DIR/bin/activate"
        source "$CONFIG_FILE"
    fi
}

# Main script execution
initialize_config

while getopts ":lum:s" option; do
    case $option in
        s)
            start_ui_server
            ;;
        m)
            model=$OPTARG
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done
# End of llm-cmd.sh