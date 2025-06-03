$EnvName = "tesla-analysis-f"

Write-Host "Deactivating any active conda environment..."
conda deactivate

Write-Host "Removing old environment (if exists)..."
conda env remove -n $EnvName

Write-Host "Cleaning up conda caches..."
conda clean --all -y

# Check Python version compatibility
$pythonVersion = (python --version).Split(" ")[1]
if ($pythonVersion -notmatch "^3\.(10|11)\.") {
    Write-Error "Unsupported Python version: $pythonVersion. Please use Python 3.10 or 3.11."
    Exit
}

# Check if environment files exist
if (-Not (Test-Path "environment.yml")) {
    Write-Error "environment.yml not found. Please ensure the file exists in the project directory."
    Exit
}
if (-Not (Test-Path "environment.dev.yml")) {
    Write-Error "environment.dev.yml not found. Please ensure the file exists in the project directory."
    Exit
}

Write-Host "Creating new environment from environment.yml..."
conda env create -n $EnvName -f environment.yml

Write-Host "Activating environment..."
conda activate $EnvName

Write-Host "Updating with dev dependencies..."
conda env update -n $EnvName -f environment.dev.yml --prune

Write-Host "Checking for missing dependencies..."
$missingPackages = @("argon2-cffi-bindings", "brotli-python", "libexpat", "libffi", "liblzma", "libsodium", "libsqlite", "libzlib")
foreach ($pkg in $missingPackages) {
    if (-Not (conda search $pkg)) {
        Write-Warning "Package $pkg is missing or incompatible. Please verify the channels or remove the package."
    }
}

Write-Host "Upgrading pip, setuptools, and wheel..."
pip install --upgrade pip setuptools wheel

Write-Host "Installing requirements..."
pip install --user -r requirements.txt --no-cache-dir
pip install --user -r requirements-dev.txt --no-cache-dir

# Handle wheel-building errors
Write-Host "Installing problematic packages from source..."
$sourceInstallPackages = @("numpy", "pandas")
foreach ($pkg in $sourceInstallPackages) {
    try {
        pip install --no-binary :all: $pkg
    }
    catch {
        Write-Warning "Failed to install $pkg from source. Please check logs for details."
    }
}

Write-Host "Environment '$EnvName' is ready!"
