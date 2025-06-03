#!/bin/bash
set -e

ENV_NAME="tesla-analysis-f"

echo "Deactivating any active conda environment..."
conda deactivate || true

echo "Removing old environment (if exists)..."
conda env remove -n $ENV_NAME || true

echo "Cleaning up conda caches..."
conda clean --all -y

echo "Creating new environment from environment.yml..."
conda env create -n $ENV_NAME -f environment.yml

echo "Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

echo "Updating with dev dependencies..."
conda env update -n $ENV_NAME -f environment.dev.yml --prune

echo "Environment '$ENV_NAME' is ready!"
