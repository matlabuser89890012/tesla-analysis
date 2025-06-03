# Add Python Scripts to PATH
$userScriptsPath = [System.IO.Path]::Combine($env:APPDATA, "Python", "Python313", "Scripts")

# Check if the directory exists
if (Test-Path $userScriptsPath) {
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    
    # Add Scripts directory if not already in PATH
    if ($currentPath -notlike "*$userScriptsPath*") {
        $newPath = "$currentPath;$userScriptsPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "Added $userScriptsPath to User PATH"
        
        # Also add to current session
        $env:PATH = "$env:PATH;$userScriptsPath"
    }
    else {
        Write-Host "Scripts path already in PATH"
    }
}
else {
    Write-Host "Warning: Python Scripts directory not found at $userScriptsPath"
}

Write-Host "`nTry running: sphinx-build --version"
