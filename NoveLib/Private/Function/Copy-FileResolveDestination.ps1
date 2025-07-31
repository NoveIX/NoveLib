# File: NoveLib\Private\Function\Copy-FileResolveDestination.ps1

function Copy-FileResolveDestination {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$File,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [switch]$Ensure
    )

    # Calculate path relative path on destination path
    [string]$relativePath = $File.FullName.Substring((Resolve-Path $Source).Path.Length)
    [string]$destPath = Join-Path -Path $Destination -ChildPath $relativePath


    if ($Ensure) {
        if ($File.PSIsContainer) {
            Test-Directory -Ensure -Path $destPath | Out-Null
        }
        else {
            [string]$destDir = Split-Path -Path $destPath -Parent
            Test-Directory -Ensure -Path $destDir | Out-Null
        }
    }

    return $destPath
}
