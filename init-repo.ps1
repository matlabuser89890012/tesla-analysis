# Run in Windows PowerShell
Write-Host "🔄 Initializing Tesla Stock Analysis Repository..."

try {
    # Initialize Git repository if not already initialized
    if (-not (Test-Path ".git")) {
        Write-Host "Initializing Git repository..."
        git init
        git config core.autocrlf false
    }

    # Configure Git
    Write-Host "Configuring Git..."
    git config user.name "matlabuser89890012"
    git config user.email "your.email@example.com"

    # Remove existing remote if any
    git remote remove origin 2>$null

    # Add correct remote
    Write-Host "Setting up remote repository..."
    git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"

    # Stage all files
    Write-Host "Staging files..."
    git add .

    # Commit changes
    Write-Host "Creating initial commit..."
    git commit -m "Initial commit: Tesla Stock Analysis Platform" -q

    # Set main as default branch
    git checkout -B main

    Write-Host "✅ Repository initialized successfully!"
    Write-Host "Next steps:"
    Write-Host "1. Create the repository on GitHub if not already created"
    Write-Host "2. Run: git push -u origin main"

}
catch {
    Write-Host "❌ Error: $_"
    exit 1
}
