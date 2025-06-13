# PowerShell Aliases
# Collection of useful command aliases

# Git Worktree Management
Set-Alias -Name nw -Value New-Worktree
Set-Alias -Name rw -Value Remove-Worktree

# SCP File Transfer
Set-Alias -Name scp-touch -Value Send-ScpTouch
Set-Alias -Name st -Value Send-ScpTouch

# Build Management
Set-Alias -Name Clear-Build -Value Clear-BuildDirectories
Set-Alias -Name cb -Value Clear-BuildDirectories 