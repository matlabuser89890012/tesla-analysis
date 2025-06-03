#!/bin/bash

set -e  # Exit on error

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Main setup flow
main() {
    # Initialize Git repository
    echo "🔄 Initializing Git repository..."
    if [ ! -d ".git" ]; then
        git init
        git remote remove origin 2>/dev/null || true
        git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"
    fi

    # Configure Git
    git config core.autocrlf false
    git config --global init.defaultBranch main

    # Setup Conda environment
    echo "🐍 Setting up Conda environment..."
    conda env update -f environment.yml
    conda activate tesla-analysis

    # Install Python requirements
    echo "📦 Installing Python packages..."
    pip install -r requirements.txt -r requirements-dev.txt

    # Start Docker services
    echo "🐳 Starting Docker services..."
    docker compose down --volumes --remove-orphans
    docker compose build --no-cache

    # Start services in order
    echo "Starting notebook service..."
    docker compose up -d --build notebook
    
    echo "Starting app service..."
    docker compose up -d --build app
    
    echo "Starting TorchServe..."
    docker compose up -d --build torchserve

    # Check GPU support
    echo "🎮 Checking GPU support..."
    docker exec -it tesla-stock-analysis-notebook python /app/codes/check_gpu.py

    # Stage and commit changes
    echo "📝 Committing changes..."
    git add .
    git commit -m "Setup completed: Tesla Stock Analysis Platform"

    # Push to remote
    echo "⬆️ Pushing to remote..."
    git push -u origin main

    echo -e "\n✅ Setup completed successfully!"
    echo "Access services at:"
    echo "- Jupyter Notebook: http://localhost:8888"
    echo "- Dashboard App: http://localhost:8050"
    echo "- TorchServe API: http://localhost:8080"
}

# Run main function
main "$@" || handle_error "Setup failed"
