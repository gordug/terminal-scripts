# Git Worktree Management Functions
# Functions for creating and managing Git worktrees with ticket-based organization

# Set the path for worktrees
$env:WORKTREE_PATH = "C:\Dev"

# Note: Helper functions Select-FromMatches and Confirm-Action are loaded from UtilityHelpers.ps1

# Create new worktree based on ticket number
function New-Worktree {
    param (
        [string]$ticketNumber
    )

    # Fetch the latest branches from the remote
    git fetch

    # Find branches containing the ticket number
    $branches = git branch -r | Select-String -Pattern $ticketNumber

    # Check if any branches were found
    if ($null -eq $branches -or $branches.Count -eq 0) {
        Write-Host "No matching branches found for search: '$ticketNumber'."    
        return
    }

    $selectedBranchMatch = Select-FromMatches -matches $branches -searchTerm $ticketNumber -itemType "branch"
    if ($null -eq $selectedBranchMatch) { return }

    $selectedBranch = $selectedBranchMatch.ToString().Trim()

    # Extract branch name from remote branch reference
    $branchName = $selectedBranch -replace 'origin/', ''

    # Create the worktree
    $worktreePath = Join-Path -Path $env:WORKTREE_PATH -ChildPath "$ticketNumber"
    git worktree add --checkout -b $branchName $worktreePath $selectedBranch    
    Write-Host "Worktree created at $worktreePath for branch $selectedBranch"   
}

# Remove worktrees with search and confirmation
function Remove-Worktree {
    param (
        [string]$searchTerm
    )
    # Get all worktrees
    $worktrees = git worktree list | Select-String -Pattern $searchTerm

    $selectedWorktreeMatch = Select-FromMatches -matches $worktrees -searchTerm $searchTerm -itemType "worktree"
    if ($null -eq $selectedWorktreeMatch) { return }

    $selectedWorktree = $selectedWorktreeMatch.ToString().Split()[0]

    # Confirm removal
    Write-Host "Removing worktree: $selectedWorktree"
    if (-not (Confirm-Action -message "Are you sure you want to remove the worktree '$selectedWorktree'?")) {
        Write-Host "Operation cancelled."
        return
    }

    # Remove the worktree
    git worktree remove $selectedWorktree
    Write-Host "Worktree '$selectedWorktree' removed."
} 