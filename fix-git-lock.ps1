# Stop on first error
$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing Git lock issues..."

try {
    # Remove Git lock files if they exist
    $lockFiles = @(
        ".git/index.lock",
        ".git/HEAD.lock",
        ".git/refs/heads/main.lock"
    )

    foreach ($file in $lockFiles) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "Removed lock file: $file"
        }
    }

    # Reset Git state
    Write-Host "Resetting Git state..."
    git config --global --add safe.directory "*"
    
    # Clean untracked files
    git clean -fdx
    
    # Reset any in-progress operations
    git reset --hard HEAD

    # Remove and reinitialize Git
    Write-Host "Reinitializing Git repository..."
    Remove-Item -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue
    git init
    
    # Configure Git
    Write-Host "Configuring Git..."
    git config core.autocrlf false
    git config --local user.name "matlabuser89890012"
    git config --local user.email "your.email@example.com"
    
    # Add remote
    Write-Host "Setting up remote..."
    git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"
    
    # Stage and commit
    Write-Host "Creating initial commit..."
    git add .
    git commit -m "Initial commit: Tesla Stock Analysis Platform"
    
    # Switch to main branch
    git checkout -B main
    
    Write-Host "✅ Git repository has been fixed and reinitialized."
    Write-Host "You can now run: git push -u origin main --force"

}
catch {
    Write-Host "❌ Error: $_"
    exit 1
}
