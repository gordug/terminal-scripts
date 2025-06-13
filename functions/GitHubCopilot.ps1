# GitHub Copilot Integration
# Functions for GitHub Copilot CLI integration

# GitHub Copilot Shell function
function Invoke-GitHubCopilotSuggest {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments)]
        [string[]]$Prompt,
        
        [ValidateSet('gh', 'git', 'shell')]
        [string]$Target = 'shell',
        
        [string]$Hostname
    )
    
    # Check if GitHub CLI is installed
    if (-not (Get-Command 'gh' -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first: winget install GitHub.cli"
        return
    }
    
    # Check if copilot extension is installed
    $copilotInstalled = gh extension list | Select-String "github/gh-copilot"
    if (-not $copilotInstalled) {
        Write-Warning "GitHub Copilot extension not found. Installing..."
        try {
            gh extension install github/gh-copilot
        }
        catch {
            Write-Error "Failed to install GitHub Copilot extension: $($_.Exception.Message)"
            return
        }
    }
    
    # Build the command
    $promptString = $Prompt -join ' '
    $command = "gh copilot suggest -t $Target"
    
    if ($Hostname) {
        $env:GH_HOST = $Hostname
    }
    
    if ($promptString) {
        $command += " '$promptString'"
    }
    
    # Execute the command
    try {
        Invoke-Expression $command
    }
    catch {
        Write-Error "Failed to execute GitHub Copilot: $($_.Exception.Message)"
    }
    finally {
        # Clean up environment variables
        if ($Hostname) {
            Remove-Item Env:GH_HOST -ErrorAction SilentlyContinue
        }
    }
}

# GitHub Copilot Explain function
function Invoke-GitHubCopilotExplain {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments)]
        [string[]]$Command
    )
    
    # Check if GitHub CLI is installed
    if (-not (Get-Command 'gh' -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first: winget install GitHub.cli"
        return
    }
    
    $commandString = $Command -join ' '
    if ($commandString) {
        gh copilot explain $commandString
    } else {
        gh copilot explain
    }
}

# Note: Aliases are defined in aliases/PowerShellAliases.ps1 