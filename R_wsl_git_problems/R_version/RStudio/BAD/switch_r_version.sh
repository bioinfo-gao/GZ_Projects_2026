#!/bin/bash

# R Version Switcher for RStudio Server
# Usage: ./switch_r_version.sh [seurat|spatial]

CONFIG_FILE="$HOME/.config/rstudio/rsession.conf"

case "$1" in
    "seurat")
        echo "Switching to Seurat environment (R 4.3.3)..."
        cat > "$CONFIG_FILE" << EOF
# RStudio Server User Configuration
rsession-which-r=/home/zhen/miniforge3/envs/seurat_env/bin/R
rsession-ld-library-path=/home/zhen/miniforge3/envs/seurat_env/lib
EOF
        ;;
    "spatial")
        echo "Switching to Spatial environment (R 4.5.1)..."
        cat > "$CONFIG_FILE" << EOF
# RStudio Server User Configuration  
rsession-which-r=/home/zhen/miniforge3/envs/spatial_R/bin/R
rsession-ld-library-path=/home/zhen/miniforge3/envs/spatial_R/lib
EOF
        ;;
    *)
        echo "Usage: $0 [seurat|spatial]"
        echo "Current R environments:"
        echo "  seurat   -> R 4.3.3 (seurat_env)"
        echo "  spatial  -> R 4.5.1 (spatial_R)"
        exit 1
        ;;
esac

echo "Configuration updated. Restarting RStudio Server..."
sudo rstudio-server restart
echo "Done! RStudio Server is now using the selected R version."