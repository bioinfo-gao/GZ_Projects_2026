#!/usr/bin/env bash

# Complete automated RNA-seq analysis script
# This script will install conda if needed, run the analysis, and handle activation/deactivation

set -euo pipefail

PROJECT_ROOT="/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216"
CONDA_PATH="$HOME/miniconda3"
CONDA_ENV_NAME="GZ-conda"

echo "Starting complete RNA-seq analysis workflow..."

# Function to check if conda is installed
check_conda_installed() {
    if [ -d "$CONDA_PATH" ] && [ -f "$CONDA_PATH/bin/conda" ]; then
        echo "Conda is already installed at $CONDA_PATH"
        return 0
    else
        echo "Conda not found at $CONDA_PATH"
        return 1
    fi
}

# Function to install miniconda
install_miniconda() {
    echo "Installing Miniconda..."
    
    # Download miniconda installer
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$HOME/Miniconda3-latest-Linux-x86_64.sh"
    
    # Install miniconda
    bash "$HOME/Miniconda3-latest-Linux-x86_64.sh" -b -p "$CONDA_PATH"
    
    # Remove installer
    rm "$HOME/Miniconda3-latest-Linux-x86_64.sh"
    
    echo "Miniconda installation completed!"
}

# Function to initialize conda for bash
init_conda_bash() {
    echo "Initializing conda for bash..."
    "$CONDA_PATH/bin/conda" init bash
}

# Function to activate conda environment
activate_conda_env() {
    echo "Activating conda environment..."
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    conda activate "$CONDA_ENV_NAME"
}

# Function to create the GZ-conda environment with required packages
create_gz_conda_env() {
    echo "Creating GZ-conda environment with required packages..."
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    
    # Create the environment with all required packages
    conda create -n "$CONDA_ENV_NAME" -c bioconda samtools fastqc multiqc star salmon trimmomatic -y
    
    echo "GZ-conda environment created with required packages!"
}

# Function to check if packages are installed in the environment
check_environment() {
    echo "Checking if GZ-conda environment exists and has required packages..."
    
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    
    # Try to activate the environment
    if conda activate "$CONDA_ENV_NAME"; then
        # Check for key packages
        local missing_packages=()
        
        for pkg in samtools fastqc multiqc star salmon; do
            if ! command -v $pkg &> /dev/null; then
                missing_packages+=("$pkg")
            fi
        done
        
        if [ ${#missing_packages[@]} -eq 0 ]; then
            echo "GZ-conda environment exists and all required packages are available!"
            return 0
        else
            echo "Environment exists but missing packages: ${missing_packages[*]}"
            conda deactivate
            return 1
        fi
    else
        echo "GZ-conda environment does not exist"
        return 1
    fi
}

# Function to run the RNA-seq analysis
run_analysis() {
    echo "Starting RNA-seq analysis in $PROJECT_ROOT"
    
    cd "$PROJECT_ROOT"
    
    # Clean up any previous temporary files
    rm -f .nextflow.log report.html timeline.html trace.csv flowchart.png results_mouse_9_singularity/.nextflow* 2>/dev/null || true
    
    # Activate the environment and run the nf-core/rnaseq pipeline with conda
    source "$CONDA_PATH/etc/profile.d/conda.sh"
    conda activate "$CONDA_ENV_NAME"
    
    nextflow run nf-core/rnaseq_backup_20260219_055913 \
        -r 3.21.0 \
        -offline \
        -c /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/01.fq/nfcore_custom.config \
        -profile conda \
        -resume \
        -work-dir /var/tmp/nf_work_$$ \
        -with-report report.html \
        -with-trace trace.csv \
        -with-timeline timeline.html \
        -with-dag flowchart.png \
        --input /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/samplesheet.csv \
        --outdir /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/results_mouse_9_singularity \
        --genome GRCm38 \
        --fasta '/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta' \
        --gtf '/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf' \
        --star_index '/home/songz/lhn_work/Project_2025/Project_01_bulk_rnaseq_20251021/results_mouse/genome/index/star' \
        --salmon_index '/home/songz/lhn_work/Project_2025/Project_01_bulk_rnaseq_20251021/results_mouse/genome/index/salmon' \
        --aligner 'star_salmon' \
        --skip_trimming \
        --skip_fq_lint \
        --pseudo_alignment 'salmon' \
        --run_star_gene_genomecov \
        --run_salmon_gene_length_norm \
        --rRNA_database '/home/songz/lhn_work/database/03.rRNA/local_rrna_manifest.txt'
    
    echo "Analysis completed!"
}

# Main execution logic
if ! check_conda_installed; then
    echo "Conda not installed, proceeding with installation..."
    install_miniconda
    init_conda_bash
    echo "Please restart your terminal or run 'source ~/.bashrc' and then rerun this script to continue with environment creation."
    exit 0
else
    echo "Conda is installed, checking for GZ-conda environment..."
    
    if ! check_environment; then
        echo "GZ-conda environment doesn't exist or missing packages, creating it now..."
        create_gz_conda_env
    fi
    
    # Run the actual analysis
    run_analysis
fi