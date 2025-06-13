# Terminal Scripts

A collection of PowerShell functions, aliases, and utilities for enhanced terminal productivity. This repository organizes custom PowerShell profile scripts in a maintainable structure that can be easily shared across systems.

## 🚀 Features

### Git Worktree Management
- **`New-Worktree`** (`nw`): Create new git worktrees based on ticket numbers with branch selection
- **`Remove-Worktree`** (`rw`): Remove worktrees with interactive search and confirmation

### Smart File Transfer
- **`Send-ScpTouch`** (`scp-touch`, `st`): SCP file transfer with timestamp tracking - only uploads files modified since last run

### Build Management
- **`Clear-BuildDirectories`** (`Clear-Build`, `cb`): Recursively clear all `bin` and `obj` directories

### GitHub Copilot Integration
- **`Invoke-GitHubCopilotShell`** (`ghcs`): Get shell command suggestions from GitHub Copilot
- **`Invoke-GitHubCopilotExplain`** (`ghce`): Explain shell commands using GitHub Copilot

### Helper Functions
- **`Select-FromMatches`**: Interactive selection from multiple search results
- **`Confirm-Action`**: User confirmation prompts with validation

## 📁 Repository Structure

```
terminal-scripts/
├── functions/
│   ├── UtilityHelpers.ps1         # Shared helper functions
│   ├── WorktreeManagement.ps1     # Git worktree functions
│   ├── ScpFileTransfer.ps1        # SCP with timestamp tracking
│   ├── BuildUtilities.ps1         # Build management utilities
│   └── GitHubCopilot.ps1          # GitHub Copilot integration
├── aliases/
│   └── PowerShellAliases.ps1      # Command aliases
├── config/
│   └── Environment.ps1            # Environment setup (oh-my-posh, chocolatey, etc.)
├── profile.ps1                    # Main profile loader
├── install.ps1                    # Installation script with dependency checking
├── LICENSE                        # MIT License
└── README.md                      # This file
```

## 🛠️ Installation

### Option 1: Automatic Installation (Recommended)
```powershell
# Clone the repository
git clone <your-repo-url> C:\Dev\terminal-scripts

# Navigate to the directory
cd C:\Dev\terminal-scripts

# Check dependencies and install profile
.\install.ps1 -CheckDependencies -Backup

# Or install missing dependencies automatically
.\install.ps1 -InstallDependencies -Backup
```

### Option 2: Manual Installation
1. Clone this repository to your preferred location
2. Add the following line to your PowerShell profile (`$PROFILE`):
   ```powershell
   . "C:\Path\To\terminal-scripts\profile.ps1"
   ```
3. Restart PowerShell or run `. $PROFILE`

### Installation Script Parameters
- **`-Backup`**: Create a backup of existing profile before modification
- **`-Force`**: Force overwrite existing profile configuration
- **`-CheckDependencies`**: Check for required dependencies and show status
- **`-InstallDependencies`**: Automatically install missing dependencies

### Dependencies Checked/Installed
- **Git**: Required for worktree management functions
- **GitHub CLI**: Required for Copilot integration
- **Oh My Posh**: Terminal prompt theming
- **OpenSSH Client**: Required for SCP file transfer
- **Chocolatey**: Package manager for Windows

## 📖 Usage Examples

### Git Worktree Management
```powershell
# Create a new worktree for ticket ABC-123
nw ABC-123

# Remove a worktree (with search)
rw ABC-123
```

### File Transfer
```powershell
# Transfer all modified files to remote server
st 192.168.1.100

# Transfer specific file pattern with custom login
Send-ScpTouch -Address "192.168.1.100" -SourceFilePattern "*.exe" -Login "admin"
```

### Build Management
```powershell
# Clear all bin/obj directories in current path
cb

# Clear build directories in specific path
Clear-BuildDirectories -Path "C:\Projects\MyApp"
```

### GitHub Copilot
```powershell
# Get shell command suggestion
ghcs "how to find large files"

# Get git command suggestion
ghcs -Target git "undo last commit"

# Explain a command
ghce "git rebase -i HEAD~3"
```

## ⚙️ Configuration

### Environment Variables
- **`WORKTREE_PATH`**: Base path for git worktrees (default: `C:\Dev`)

### Custom Paths
Edit `config/Environment.ps1` to customize:
- Oh-my-posh theme URL
- GitHub Copilot script path
- Other environment-specific settings

## 🔧 Customization

### Adding New Functions
1. Create a new `.ps1` file in the `functions/` directory
2. Add the file path to the `$functionFiles` array in `profile.ps1`
3. Add any aliases to `aliases/PowerShellAliases.ps1`

### Adding New Aliases
Simply add new aliases to `aliases/PowerShellAliases.ps1`:
```powershell
Set-Alias -Name myalias -Value MyFunction
```

## 🔄 Syncing Across Systems

1. **Initial Setup**: Clone this repository on each system and run `install.ps1`
2. **Updates**: Pull latest changes with `git pull`
3. **Personal Customizations**: Keep system-specific changes in separate branch or local modifications

## 🛡️ Requirements

- PowerShell 5.1 or later
- Appropriate execution policy: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Optional Dependencies (auto-detected and installable)
- **Git**: Required for worktree management functions
- **GitHub CLI**: Required for Copilot integration  
- **Oh My Posh**: Terminal prompt theming
- **OpenSSH Client**: Required for SCP file transfer functions
- **Chocolatey**: Package manager integration

Use `.\install.ps1 -CheckDependencies` to see what's installed, or `.\install.ps1 -InstallDependencies` to automatically install missing components.

## 📝 Notes

- The SCP function creates a timestamp tracking file in `$env:USERPROFILE\PowerShell\Command History\`
- Worktree functions assume origin remote and specific branching strategy
- Build clearing function targets standard .NET `bin` and `obj` directories

## 🐛 Troubleshooting

### Profile Not Loading
- Check execution policy: `Get-ExecutionPolicy`
- Set if needed: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify path in `$PROFILE` matches repository location

### Functions Not Available
- Ensure all files are present in the repository
- Check for PowerShell errors with `$Error[0]`
- Run `Test-Path` on individual script files

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details. 