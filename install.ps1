# PowerShell Profile Installation Script
# This script helps set up the custom profile on a new system

param(
    [switch]$Force,
    [switch]$Backup
)

# Get the current script directory (where terminal-scripts is located)
$TerminalScriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProfilePath = $PROFILE

Write-Host "Installing custom PowerShell profile..." -ForegroundColor Cyan
Write-Host "Terminal Scripts Path: $TerminalScriptsPath" -ForegroundColor Gray
Write-Host "Profile Path: $ProfilePath" -ForegroundColor Gray

# Create profile directory if it doesn't exist
$ProfileDir = Split-Path -Parent $ProfilePath
if (-not (Test-Path $ProfileDir)) {
    Write-Host "Creating profile directory: $ProfileDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Backup existing profile if requested
if ($Backup -and (Test-Path $ProfilePath)) {
    $BackupPath = "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Backing up existing profile to: $BackupPath" -ForegroundColor Yellow
    Copy-Item $ProfilePath $BackupPath
}

# Check if profile already exists and contains our script
$ProfileExists = Test-Path $ProfilePath
$SourceCommand = ". `"$TerminalScriptsPath\profile.ps1`""

if ($ProfileExists) {
    $existingContent = Get-Content $ProfilePath -Raw
    if ($existingContent -match [regex]::Escape($SourceCommand)) {
        if (-not $Force) {
            Write-Host "Profile already contains reference to terminal-scripts. Use -Force to override." -ForegroundColor Yellow
            return
        }
    }
}

# Add or update the profile
if ($ProfileExists -and -not $Force) {
    # Append to existing profile
    Write-Host "Appending to existing profile..." -ForegroundColor Green
    Add-Content -Path $ProfilePath -Value "`n# Load custom terminal scripts"
    Add-Content -Path $ProfilePath -Value $SourceCommand
} else {
    # Create new profile or overwrite existing one
    Write-Host "Creating new profile..." -ForegroundColor Green
    @"
# PowerShell Profile
# This profile loads custom terminal scripts from the terminal-scripts repository

# Load custom terminal scripts
$SourceCommand
"@ | Set-Content -Path $ProfilePath
}

Write-Host "Installation completed!" -ForegroundColor Green
Write-Host "Restart your PowerShell session or run: . `$PROFILE" -ForegroundColor Cyan

# Test the profile
Write-Host "Testing profile..." -ForegroundColor Yellow
try {
    . $ProfilePath
    Write-Host "Profile test successful!" -ForegroundColor Green
} catch {
    Write-Error "Profile test failed: $($_.Exception.Message)"
    Write-Host "You may need to check your execution policy: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
} 