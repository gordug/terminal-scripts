# Utility Helper Functions
# Common helper functions used across multiple modules

# Helper function to select from multiple matches
function Select-FromMatches {
    param (
        [Parameter(Mandatory=$true)]
        [array]$matches,
        [Parameter(Mandatory=$true)]
        [string]$searchTerm,
        [Parameter(Mandatory=$true)]
        [string]$itemType
    )

    if ($matches.Count -eq 0) {
        Write-Host "No matching $itemType found."
        return $null
    }

    if ($matches.Count -eq 1) {
        return $matches[0]
    }

    Write-Host "Multiple $itemType found matching search '$searchTerm':"        

    for ($i = 0; $i -lt $matches.Count; $i++) {
        Write-Host "$($i + 1): $($matches[$i].ToString().Trim())"
    }

    $selection = Read-Host "Enter the number of the $itemType to select (or 'c' to cancel)"

    if ($selection -eq 'c') {
        Write-Host "Operation cancelled."
        return $null
    }

    if (-not ($selection -as [int]) -or [int]$selection -lt 1 -or [int]$selection -gt $matches.Count) {
        Write-Host "Invalid selection. Exiting."
        return $null
    }

    return $matches[[int]$selection - 1]
}

# Helper function for confirmation
function Confirm-Action {
    param (
        [Parameter(Mandatory=$true)]
        [string]$message
    )

    $confirmation = Read-Host "$message (y/n)"
    while ($confirmation -notin @('y', 'n', 'Y', 'N')) {
        Write-Host "Please enter 'y' for yes or 'n' for no."
        $confirmation = Read-Host "$message (y/n)"
    }
    return $confirmation -eq 'y'
} 