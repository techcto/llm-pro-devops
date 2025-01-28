# System Initialization Script

This repository contains a set of scripts to initialize various system components (GPU, XPU, CPU) and install software (llamacpp from source, UI server). The main script detects the system type and performs the necessary initialization.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Scripts](#scripts)
- [Options](#options)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

- Bash
- Git
- CMake (for llamacpp)
- Make (for llamacpp)
- npm (for UI server)
- Intel and NVIDIA drivers (for XPU and GPU initialization)

## Usage

To use the main script, you can execute it directly from the command line. The script supports several options for initializing different components.

```bash
./main_script.sh [options]