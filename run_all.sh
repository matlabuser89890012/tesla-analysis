#!/bin/bash

echo "🔄 Setting up Tesla Stock Analysis environment..."

# Check for required tools
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Please install Docker first."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ curl is required but not installed. Please install curl first."; exit 1; }

# Create a GitHub repository if needed
setup_github_repo() {
  echo "Do you want to create a new GitHub repository for this project? (y/n)"
  read create_repo
  
  if [ "$create_repo" == "y" ]; then
    echo "Enter your GitHub username:"
    read github_username
    
    echo "Enter a name for your repository (default: tesla-stock-analysis):"
    read repo_name
    repo_name=${repo_name:-tesla-stock-analysis}
    
    echo "Enter your GitHub personal access token (needs repo scope):"
    read -s github_token
    
    echo "Creating repository $repo_name..."
    
    # Create repository via GitHub API
    response=$(curl -s -X POST \
      -H "Authorization: token $github_token" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/user/repos \
      -d "{\"name\":\"$repo_name\",\"description\":\"Tesla Stock Analysis Platform\",\"private\":true}"
    )
    
    # Check if repo was created successfully
    if echo "$response" | grep -q "\"name\":\"$repo_name\""; then
      echo "✅ Repository created successfully!"
      
      # Configure Git
      git init
      git config user.name "$github_username"
      git config user.email "your-email@example.com"
      
      # Add remote
      git remote add origin "https://github.com/$github_username/$repo_name.git"
      
      # Stage and commit files
      git add .
      git commit -m "Initial commit - Tesla Stock Analysis Platform"
      
      # Push to GitHub
      git push -u origin main || git push -u origin master
      
      echo "✅ Code pushed to GitHub repository: https://github.com/$github_username/$repo_name"
    else
      echo "❌ Failed to create repository. Response:"
      echo "$response"
    fi
  else
    echo "Skipping GitHub repository setup."
  fi
}

# Install dependencies
install_dependencies() {
  echo "Installing required dependencies..."
  
  # Check if running on WSL/Linux
  if [ -f /etc/os-release ]; then
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update
      sudo apt-get install -y dos2unix
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y dos2unix
    fi
  fi
  
  # Fix line endings
  if command -v dos2unix >/dev/null 2>&1; then
    echo "Converting script line endings..."
    find . -name "*.sh" -exec dos2unix {} \;
  fi
  
  # Make scripts executable
  chmod +x *.sh
  
  echo "✅ Dependencies installed."
}

# Start the containers
start_containers() {
  echo "Starting Docker containers..."
  
  # Detect Docker Compose command (support both docker-compose and docker compose)
  if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
  elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
  else
    echo "❌ Docker Compose not found!"
    exit 1
  fi
  
  # Start containers
  $DOCKER_COMPOSE up -d --build
  
  echo "✅ Containers started."
  echo "Jupyter Notebook: http://localhost:8888"
  echo "Dashboard App: http://localhost:8050"
}

# Main execution
echo "Tesla Stock Analysis Setup"
echo "=========================="
echo "This script will set up your development environment."
echo ""

install_dependencies
setup_github_repo
start_containers

echo ""
echo "🎉 Setup complete! Your Tesla Stock Analysis environment is ready."
