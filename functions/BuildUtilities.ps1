# Build Management Utilities
# Functions for managing build artifacts and cleanup

# Clear build output directories (bin/obj) recursively
function Clear-BuildDirectories {
    param(
        [string]$Path = "."
    )
    
    Write-Host "Clearing build directories in: $(Resolve-Path $Path)"
    
    try {
        $buildDirs = Get-ChildItem -Path $Path -Recurse -Directory -Include "bin","obj" -ErrorAction SilentlyContinue
        
        if ($buildDirs.Count -eq 0) {
            Write-Host "No build directories found."
            return
        }
        
        Write-Host "Found $($buildDirs.Count) build directories to clear:"
        $buildDirs | ForEach-Object { Write-Host "  - $($_.FullName)" }
        
        foreach ($dir in $buildDirs) {
            try {
                Remove-Item "$($dir.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "Cleared: $($dir.FullName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Could not clear directory: $($dir.FullName) - $($_.Exception.Message)"
            }
        }
        
        Write-Host "Build directory cleanup completed!" -ForegroundColor Green
    }
    catch {
        Write-Error "Error during build cleanup: $($_.Exception.Message)"
    }
} 