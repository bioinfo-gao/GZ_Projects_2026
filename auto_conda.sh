#!/usr/bin/env bash

# Auto-activate/deactivate conda environment based on directory
# This script should be sourced in your .bashrc

CONDA_ACTIVATED=false
CURRENT_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDA_ENV_NAME="GZ-conda"

# Function to check if we're in the project directory
check_project_dir() {
    local current_dir=$(pwd)
    
    # Check if current directory is under the project directory
    if [[ "$current_dir" == "$CURRENT_PROJECT_DIR"* ]]; then
        if [ "$CONDA_ACTIVATED" = false ]; then
            # Activate conda environment
            source $HOME/miniconda3/etc/profile.d/conda.sh
            conda activate $CONDA_ENV_NAME
            CONDA_ACTIVATED=true
            echo "Conda environment '$CONDA_ENV_NAME' activated automatically."
        fi
    else
        if [ "$CONDA_ACTIVATED" = true ]; then
            # Deactivate conda environment
            conda deactivate
            CONDA_ACTIVATED=false
            echo "Conda environment '$CONDA_ENV_NAME' deactivated automatically."
        fi
    fi
}

# Function to force activation
activate_conda_here() {
    if [ "$CONDA_ACTIVATED" = false ]; then
        source $HOME/miniconda3/etc/profile.d/conda.sh
        conda activate $CONDA_ENV_NAME
        CONDA_ACTIVATED=true
        echo "Conda environment '$CONDA_ENV_NAME' activated."
    fi
}

# Function to force deactivation
deactivate_conda_here() {
    if [ "$CONDA_ACTIVATED" = true ]; then
        conda deactivate
        CONDA_ACTIVATED=false
        echo "Conda environment '$CONDA_ENV_NAME' deactivated."
    fi
}

# Set up the PROMPT_COMMAND to run the check on every command
PROMPT_COMMAND="check_project_dir; $PROMPT_COMMAND"

# Initial check in case we're already in the project directory
check_project_dir