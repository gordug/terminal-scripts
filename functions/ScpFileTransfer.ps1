# SCP File Transfer with Timestamp Tracking
# Smart file transfer that only uploads files modified since last run

function Send-ScpTouch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Address,

        [Parameter(Mandatory=$false)]
        [string]$SourceFilePattern = "*",

        [Parameter(Mandatory=$false)]
        [string]$DestinationFilePattern = $null,

        [Parameter(Mandatory=$false)]
        [string]$Login = "root"
    )
    $Address = $Address.TrimEnd(':')  # Ensure no trailing colon
    if (-not $Address) {
        Write-Error "Address parameter is required."
        return
    }

    $Address = "$login@$Address"  # Prepend login to the address

    # Define config directory and file paths
    $configDir = Join-Path -Path $env:USERPROFILE -ChildPath "PowerShell\Command History"
    $currentDir = Get-Location
    $configFileName = "Send-ScpTouch.json"
    $configFilePath = Join-Path -Path $configDir -ChildPath $configFileName     

    # Ensure config directory exists
    if (-not (Test-Path -Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        Write-Host "Created config directory: $configDir"
    }

    # Load existing config or create new one
    $config = @{}
    if (Test-Path -Path $configFilePath) {
        try {
            $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
            $config = @{}
            $configContent.PSObject.Properties | ForEach-Object {
                $config[$_.Name] = [DateTime]::Parse($_.Value)
            }
        }
        catch {
            Write-Warning "Could not parse config file. Starting with empty config."
            $config = @{}
        }
    }

    # Get the last run timestamp for current directory
    $currentDirKey = $currentDir.Path
    $lastRunTime = $config[$currentDirKey]

    if ($null -eq $lastRunTime) {
        Write-Host "First run from directory: $currentDirKey"
        $lastRunTime = [DateTime]::MinValue
    } else {
        Write-Host "Last run from this directory: $lastRunTime"
    }

    # Find files matching the pattern that are newer than last run
    $filesToTransfer = @()

    try {
        $allFiles = Get-ChildItem -Path . -Filter $SourceFilePattern -Recurse   
        $filesToTransfer = $allFiles | Where-Object { $_.LastWriteTime -gt $lastRunTime }
    }
    catch {
        Write-Error "Error finding files with pattern '$SourceFilePattern': $($_.Exception.Message)"
        return
    }

    if ($filesToTransfer.Count -eq 0) {
        Write-Host "No files found that are newer than last run timestamp."     
        return
    }

    Write-Host "Found $($filesToTransfer.Count) file(s) to transfer:"
    $filesToTransfer | ForEach-Object { Write-Host "  - $($_.FullName) (Modified: $($_.LastWriteTime))" }

    # Confirm transfer
    if (-not (Confirm-Action -message "Transfer these files? ($Address :~/)")) {
        Write-Host "Transfer cancelled."
        return
    }

    # Perform SCP transfer
    $transferSuccess = $true
    $currentTime = Get-Date

    foreach ($file in $filesToTransfer) {
        try {
            # Calculate relative path from current directory
            $relativePath = $file.FullName.Substring($currentDir.Path.Length + 1)

            # Determine destination file name
            $destFileName = if ($DestinationFilePattern) {
                $DestinationFilePattern
            } else {
                $relativePath -replace '\\', '/'  # Convert Windows paths to Unix paths
            }

            $destPath = "~/$destFileName"

            Write-Host "Transferring: $($file.Name) -> $destPath"

            # Execute SCP command
            $scpCommand = "scp `"$($file.FullName)`" $Address`:$destPath"       
            Write-Host "Executing: $scpCommand"

            $result = Invoke-Expression $scpCommand

            if ($LASTEXITCODE -ne 0) {
                Write-Error "SCP transfer failed: $($result.ToString().Trim())" 
                $transferSuccess = $false
            } else {
                Write-Host "Successfully transferred: $($file.Name)"
            }
        }
        catch {
            Write-Error "Error transferring file $($file.Name): $($_.Exception.Message)"
            $transferSuccess = $false
        }
    }

    # Update timestamp only if all transfers were successful
    if ($transferSuccess) {
        $config[$currentDirKey] = $currentTime

        # Save updated config
        try {
            $configToSave = @{}
            $config.Keys | ForEach-Object {
                $configToSave[$_] = $config[$_].ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            }
            $configToSave | ConvertTo-Json | Set-Content -Path $configFilePath  
            Write-Host "Updated timestamp for directory: $currentDirKey"        
            Write-Host "All files transferred successfully!"
        }
        catch {
            Write-Warning "Could not save config file: $($_.Exception.Message)" 
        }
    } else {
        Write-Warning "Some transfers failed. Timestamp not updated."
    }
} 