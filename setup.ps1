# Detect environment
$isWSL = $env:WSL_DISTRO_NAME -ne $null
$isWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $PSVersionTable.OS -like '*Windows*'

# Function to handle errors
function Handle-Error {
    param($ErrorMessage)
    Write-Host "❌ Error: $ErrorMessage" -ForegroundColor Red
    exit 1
}

try {
    # Initialize Git repository
    Write-Host "🔄 Initializing Git repository..."
    if (!(Test-Path ".git")) {
        git init
        git remote remove origin 2>$null
        git remote add origin "https://github.com/matlabuser89890012/tesla-analysis.git"
    }

    # Configure Git
    git config core.autocrlf false
    git config --global init.defaultBranch main

    # Setup Conda environment
    Write-Host "🐍 Setting up Conda environment..."
    if ($isWSL) {
        bash -c "conda env update -f environment.yml"
        bash -c "conda activate tesla-analysis"
    } else {
        conda env update -f environment.yml
        conda activate tesla-analysis
    }

    # Install Python requirements
    Write-Host "📦 Installing Python packages..."
    pip install -r requirements.txt -r requirements-dev.txt

    # Start Docker services
    Write-Host "🐳 Starting Docker services..."
    docker compose down --volumes --remove-orphans
    docker compose build --no-cache

    # Start services in order
    Write-Host "Starting notebook service..."
    docker compose up -d --build notebook
    
    Write-Host "Starting app service..."
    docker compose up -d --build app
    
    Write-Host "Starting TorchServe..."
    docker compose up -d --build torchserve

    # Check GPU support
    Write-Host "🎮 Checking GPU support..."
    docker exec -it tesla-stock-analysis-notebook python /app/codes/check_gpu.py

    # Stage and commit changes
    Write-Host "📝 Committing changes..."
    git add .
    git commit -m "Setup completed: Tesla Stock Analysis Platform"

    # Push to remote
    Write-Host "⬆️ Pushing to remote..."
    git push -u origin main

    Write-Host "`n✅ Setup completed successfully!"
    Write-Host "Access services at:"
    Write-Host "- Jupyter Notebook: http://localhost:8888"
    Write-Host "- Dashboard App: http://localhost:8050"
    Write-Host "- TorchServe API: http://localhost:8080"

} catch {
    Handle-Error $_.Exception.Message
}
