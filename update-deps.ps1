# Run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    Break
}

Write-Host "Updating Python dependencies..."

# Add Python Scripts to PATH
$pythonScripts = @(
    [System.IO.Path]::Combine($env:APPDATA, "Python", "Python313", "Scripts"),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "Python", "Python313", "Scripts")
)

foreach ($path in $pythonScripts) {
    if (Test-Path $path) {
        $env:Path = "$path;" + $env:Path
    }
}

# Uninstall problematic packages
pip uninstall -y sphinx sphinx-rtd-theme nbsphinx sphinx-autodoc-typehints

# Clear pip cache
Remove-Item -Path "$env:LOCALAPPDATA\pip\Cache" -Recurse -Force -ErrorAction SilentlyContinue

# Check if requirements files exist
if (-Not (Test-Path "requirements.txt")) {
    Write-Error "requirements.txt not found. Please ensure the file exists in the project directory."
    Exit
}
if (-Not (Test-Path "requirements-dev.txt")) {
    Write-Error "requirements-dev.txt not found. Please ensure the file exists in the project directory."
    Exit
}

# Install requirements
Write-Host "Installing requirements..."
pip install --user -r requirements.txt --no-cache-dir
pip install --user -r requirements-dev.txt --no-cache-dir

# Verify Sphinx installation
Write-Host "Verifying Sphinx installation..."
sphinx-build --version

Write-Host "Done! Please restart your shell to use the updated PATH."
