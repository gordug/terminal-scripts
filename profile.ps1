# PowerShell Profile - Main Entry Point
# This script loads all custom functions, aliases, and configurations
# Place this repository path in your $PROFILE or source it from there

# Get the directory where this script is located
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load Environment Configuration
$envConfig = Join-Path $ScriptRoot "config\Environment.ps1"
if (Test-Path $envConfig) {
    . $envConfig
} else {
    Write-Warning "Environment configuration not found at: $envConfig"
}

# Load Function Modules
$functionFiles = @(
    "functions\UtilityHelpers.ps1",
    "functions\WorktreeManagement.ps1",
    "functions\ScpFileTransfer.ps1", 
    "functions\BuildUtilities.ps1",
    "functions\GitHubCopilot.ps1"
)

foreach ($functionFile in $functionFiles) {
    $fullPath = Join-Path $ScriptRoot $functionFile
    if (Test-Path $fullPath) {
        . $fullPath
        Write-Verbose "Loaded: $functionFile"
    } else {
        Write-Warning "Function file not found: $fullPath"
    }
}

# Load Aliases
$aliasFile = Join-Path $ScriptRoot "aliases\PowerShellAliases.ps1"
if (Test-Path $aliasFile) {
    . $aliasFile
    Write-Verbose "Loaded aliases"
} else {
    Write-Warning "Alias file not found: $aliasFile"
}

Write-Host "Custom PowerShell profile loaded successfully!" -ForegroundColor Green 