# File: NoveLib\Private\Function\Copy-FileDir.ps1

function Copy-FileDir {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$Dirs,
        [Parameter(Mandatory = $true)]
        [switch]$CopyEmptyFolder
    )

    if ($CopyEmptyFolder) {
        $Script:Activity_NoveLibFX = "Copy empty folder and restore attribute folder..."
    }
    else {
        $Script:Activity_NoveLibFX = "Restore attribute folder..."
    }

    # Recupera tutte le cartelle nella destinazione (già esistenti o appena copiate)
    [array]$destDirs = Get-All -Dir -Path $Destination

    foreach ($dir in $Dirs) {
        try {
            # Restore empty folder and calculate destination target
            [string]$destDir = Copy-FileResolveDestination -File $dir -Source $Source `
                -Destination $Destination -Ensure:$CopyEmptyFolder

            # Search the list of destination folders
            [string]$existsDir = $destDirs | Where-Object { $_.FullName -eq $destDir }

            # Restore attribute
            if ($null -ne $existsDir) {
                Copy-ItemAttribute -Source $dir.FullName -Destination $destDir
            }
            else {
                #Write-Warning "Cartella corrispondente non trovata per '$($dir.FullName)'"
            }
        }
        finally {
            $Script:CurrentFile_NoveLibFX++
        }

        # Display progress bar
        Copy-FileDisplayMode -File $dir
    }
}