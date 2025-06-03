# Run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    Break
}

Write-Host "🔄 Fixing Docker Desktop and WSL Integration..."

# Function to handle errors
function Handle-Error {
    param($ErrorMessage)
    Write-Host "❌ Error: $ErrorMessage" -ForegroundColor Red
    exit 1
}

try {
    # 1. Stop Docker Desktop
    Write-Host "Stopping Docker Desktop..."
    Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
    
    # 2. Reset WSL
    Write-Host "Resetting WSL..."
    wsl --shutdown
    
    # 3. Check and enable required Windows features
    Write-Host "Checking Windows features..."
    $features = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform"
    )
    
    foreach ($feature in $features) {
        if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -ne "Enabled") {
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
        }
    }
    
    # 4. Set WSL 2 as default
    Write-Host "Setting WSL 2 as default..."
    wsl --set-default-version 2
    
    # 5. Update Ubuntu-22.04
    Write-Host "Updating Ubuntu-22.04..."
    wsl --update
    wsl -d Ubuntu-22.04 apt update
    wsl -d Ubuntu-22.04 apt upgrade -y
    
    # 6. Restart Docker Desktop
    Write-Host "Starting Docker Desktop..."
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    # 7. Wait for Docker to start
    Write-Host "Waiting for Docker to start..."
    $retries = 0
    do {
        Start-Sleep -Seconds 5
        $retries++
        docker info > $null 2>&1
    } while ($LASTEXITCODE -ne 0 -and $retries -lt 12)
    
    # 8. Check Docker status
    if (docker info) {
        Write-Host "✅ Docker is running properly!"
    }
    else {
        throw "Docker is not responding"
    }
    
    # 9. Test WSL integration
    Write-Host "Testing WSL integration..."
    wsl -d Ubuntu-22.04 docker version
    
    Write-Host "`n✅ Fix completed successfully!"
    Write-Host "Please try your Docker commands again."
    
}
catch {
    Handle-Error $_.Exception.Message
}
