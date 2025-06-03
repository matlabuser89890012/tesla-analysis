#!/bin/bash

set -e  # Exit on error

echo "🔄 Initializing Tesla Stock Analysis Repository in WSL..."

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Installing..."
        sudo apt-get update && sudo apt-get install -y $1
    fi
}

# Install required tools
check_command git
check_command curl

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git config core.autocrlf false
fi

# Configure Git
echo "Configuring Git..."
git config user.name "matlabuser89890012"
git config user.email "your.email@example.com"

# Remove existing remote if any
git remote remove origin 2>/dev/null || true

# Add correct remote
echo "Setting up remote repository..."
git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"

# Stage all files
echo "Staging files..."
git add .

# Commit changes
echo "Creating initial commit..."
git commit -m "Initial commit: Tesla Stock Analysis Platform" || true

# Set main as default branch
git checkout -B main

echo "✅ Repository initialized successfully!"
echo "Next steps:"
echo "1. Create the repository on GitHub if not already created"
echo "2. Run: git push -u origin main"
