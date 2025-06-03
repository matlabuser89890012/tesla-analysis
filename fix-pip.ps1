# Run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    Break
}

Write-Host "[*] Fixing pip permissions..."

# Fix permissions for pip cache directory
$pipCacheDir = "$env:USERPROFILE\AppData\Local\pip\Cache"
if (-not (Test-Path $pipCacheDir)) {
    New-Item -ItemType Directory -Path $pipCacheDir -Force
}
icacls $pipCacheDir /grant "${env:USERNAME}:(OI)(CI)F" /T
Write-Host "[+] Fixed permissions for pip cache"

# Fix permissions for site-packages
$condaPath = & conda info --base
$envPath = Join-Path $condaPath "envs\tesla-analysis\Lib\site-packages"
if (Test-Path $envPath) {
    icacls $envPath /grant "${env:USERNAME}:(OI)(CI)F" /T
    Write-Host "[+] Fixed permissions for site-packages"
}
else {
    Write-Host "[!] Could not find site-packages directory"
}

# Upgrade pip
Write-Host "[*] Upgrading pip..."
python -m pip install --upgrade pip --user
Write-Host "[+] Upgraded pip"

# Install requirements with --user flag
Write-Host "[*] Installing requirements..."
if (Test-Path "requirements.txt") {
    pip install -r requirements.txt --user
}
if (Test-Path "requirements-dev.txt") {
    pip install -r requirements-dev.txt --user
}

Write-Host "`n[+] All fixes applied. Try running your pip install commands again."
Write-Host "Example: pip install -r requirements.txt --user"
