# PowerShell Profile Installation Script
# This script helps set up the custom profile on a new system

param(
    [switch]$Force,
    [switch]$Backup,
    [switch]$CheckDependencies,
    [switch]$InstallDependencies
)

# Dependency Management Functions
function Test-Dependency {
    param(
        [string]$Command,
        [string]$Name,
        [string]$InstallCommand = $null,
        [string]$CheckCommand = $null
    )
    
    $result = @{
        Name = $Name
        Command = $Command
        Installed = $false
        InstallCommand = $InstallCommand
        Version = $null
    }
    
    try {
        if ($CheckCommand) {
            $output = Invoke-Expression $CheckCommand -ErrorAction SilentlyContinue
            $result.Installed = $LASTEXITCODE -eq 0
            $result.Version = $output
        } else {
            $cmd = Get-Command $Command -ErrorAction SilentlyContinue
            $result.Installed = $null -ne $cmd
            if ($cmd) {
                $result.Version = $cmd.Version
            }
        }
    } catch {
        $result.Installed = $false
    }
    
    return $result
}

function Install-Dependency {
    param(
        [string]$InstallCommand,
        [string]$Name
    )
    
    if (-not $InstallCommand) {
        Write-Warning "No installation command available for $Name"
        return $false
    }
    
    Write-Host "Installing $Name..." -ForegroundColor Yellow
    try {
        Invoke-Expression $InstallCommand
        return $LASTEXITCODE -eq 0
    } catch {
        Write-Error "Failed to install $Name': $($_.Exception.Message)"
        return $false
    }
}

function Test-AllDependencies {
    $dependencies = @(
        @{
            Command = "git"
            Name = "Git"
            InstallCommand = "winget install Git.Git"
            CheckCommand = "git --version"
        },
        @{
            Command = "gh"
            Name = "GitHub CLI"
            InstallCommand = "winget install GitHub.cli"
            CheckCommand = "gh --version"
        },
        @{
            Command = "oh-my-posh"
            Name = "Oh My Posh"
            InstallCommand = "winget install JanDeDobbeleer.OhMyPosh"
            CheckCommand = "oh-my-posh --version"
        },
        @{
            Command = "scp"
            Name = "OpenSSH Client"
            InstallCommand = "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
            CheckCommand = "scp"
        },
        @{
            Command = "choco"
            Name = "Chocolatey"
            InstallCommand = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            CheckCommand = "choco --version"
        }
    )
    
    $results = @()
    foreach ($dep in $dependencies) {
        $result = Test-Dependency -Command $dep.Command -Name $dep.Name -InstallCommand $dep.InstallCommand -CheckCommand $dep.CheckCommand
        $results += $result
    }
    
    return $results
}

function Show-DependencyStatus {
    param([array]$Dependencies)
    
    Write-Host "`n📋 Dependency Status:" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    foreach ($dep in $Dependencies) {
        $status = if ($dep.Installed) { "✅ Installed" } else { "❌ Missing" }
        $version = if ($dep.Version) { " ($($dep.Version))" } else { "" }
        Write-Host "$($dep.Name): $status$version"
    }
    
    $missing = $Dependencies | Where-Object { -not $_.Installed }
    if ($missing.Count -gt 0) {
        Write-Host "`n⚠️  Missing dependencies:" -ForegroundColor Yellow
        foreach ($dep in $missing) {
            Write-Host "  - $($dep.Name)" -ForegroundColor Red
            if ($dep.InstallCommand) {
                Write-Host "    Install: $($dep.InstallCommand)" -ForegroundColor Gray
            }
        }
        return $false
    } else {
        Write-Host "`n✅ All dependencies are installed!" -ForegroundColor Green
        return $true
    }
}

# Get the current script directory (where terminal-scripts is located)
$TerminalScriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProfilePath = $PROFILE

# Handle dependency checking if requested
if ($CheckDependencies -or $InstallDependencies) {
    Write-Host "Checking dependencies..." -ForegroundColor Cyan
    $deps = Test-AllDependencies
    $allInstalled = Show-DependencyStatus -Dependencies $deps
    
    if ($InstallDependencies -and -not $allInstalled) {
        Write-Host "`n🔧 Installing missing dependencies..." -ForegroundColor Yellow
        $missing = $deps | Where-Object { -not $_.Installed }
        
        foreach ($dep in $missing) {
            $success = Install-Dependency -InstallCommand $dep.InstallCommand -Name $dep.Name
            if ($success) {
                Write-Host "✅ Successfully installed $($dep.Name)" -ForegroundColor Green
            } else {
                Write-Host "❌ Failed to install $($dep.Name)" -ForegroundColor Red
            }
        }
        
        # Re-check dependencies after installation
        Write-Host "`n🔍 Re-checking dependencies..." -ForegroundColor Cyan
        $deps = Test-AllDependencies
        Show-DependencyStatus -Dependencies $deps | Out-Null
    }
    
    if ($CheckDependencies -and -not $InstallDependencies) {
        Write-Host "`nRun with -InstallDependencies to automatically install missing dependencies." -ForegroundColor Yellow
        return
    }
}

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