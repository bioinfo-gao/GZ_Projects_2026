#!/bin/bash

# R version switcher script for WSL with mamba environments

RSTUDIO_CONFIG="/home/zhen/.config/rstudio/rsession.conf"

# Function to display usage
usage() {
    echo "Usage: $0 [seurat|spatial]"
    echo "  seurat   - Switch to R 4.3.3 (seurat_env)"
    echo "  spatial  - Switch to R 4.5.1 (spatial_R)"
    exit 1
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Switch based on argument
case $1 in
    "seurat")
        echo "Switching to R 4.3.3 (seurat_env)..."
        cat > "$RSTUDIO_CONFIG" << EOF
# R session configuration for RStudio Server
rsession-which-r=/home/zhen/miniforge3/envs/seurat_env/bin/R
EOF
        echo "Done! Restart RStudio Server to apply changes."
        ;;
    "spatial")
        echo "Switching to R 4.5.1 (spatial_R)..."
        cat > "$RSTUDIO_CONFIG" << EOF
# R session configuration for RStudio Server
rsession-which-r=/home/zhen/miniforge3/envs/spatial_R/bin/R
EOF
        echo "Done! Restart RStudio Server to apply changes."
        ;;
    *)
        echo "Error: Invalid option '$1'"
        usage
        ;;
esac