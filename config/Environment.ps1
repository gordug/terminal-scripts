# Environment Configuration
# Setup for various development tools and environment variables

# Oh-my-posh theme initialization
oh-my-posh.exe --init --shell pwsh --config 'https://raw.githubusercontent.com/gordug/posh/refs/heads/main/solarized_dark.omp.json' | Invoke-Expression

# Chocolatey Profile Import
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# GitHub Copilot integration is now handled by functions/GitHubCopilot.ps1 