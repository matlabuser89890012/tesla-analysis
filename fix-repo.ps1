# Stop on first error
$ErrorActionPreference = "Stop"

Write-Host "🔄 Fixing Git repository setup..."

# Function to handle errors
function Handle-Error {
    param($ErrorMessage)
    Write-Host "❌ Error: $ErrorMessage" -ForegroundColor Red
    exit 1
}

try {
    # Reset Git state
    Write-Host "Resetting Git state..."
    git remote remove origin
    
    # Initialize fresh repository
    Write-Host "Initializing fresh repository..."
    Remove-Item -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue
    git init
    
    # Configure Git
    Write-Host "Configuring Git..."
    git config core.autocrlf false
    git config --global init.defaultBranch main
    
    # Create .gitignore if it doesn't exist
    if (-not (Test-Path ".gitignore")) {
        @"
__pycache__/
*.py[cod]
.env
.venv/
*.so
.Python
.coverage
.pytest_cache/
.jupyter/
.ipynb_checkpoints/
"@ | Out-File -FilePath ".gitignore" -Encoding utf8
    }

    # Stage all files
    Write-Host "Staging files..."
    git add .

    # Initial commit
    Write-Host "Creating initial commit..."
    git commit -m "Initial commit: Tesla Stock Analysis Platform"

    # Add new remote
    Write-Host "Adding remote repository..."
    git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"
    
    Write-Host "✅ Repository has been reset and reconfigured."
    Write-Host "Now run: git push -u origin main --force"
    
}
catch {
    Handle-Error $_.Exception.Message
}
