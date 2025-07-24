# File: NoveLib\Private\Function\Copy-FileResolveDestination.ps1

function Copy-FileResolveDestination {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$File,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    # Resolve and create dir if necessary
    [string]$relativePath = $File.FullName.Substring((Resolve-Path $Source).Path.Length)
    [string]$destPath = Join-Path -Path $Destination -ChildPath $relativePath
    [string]$destDir = Split-Path -Path $destPath -Parent
    Test-Directory -Ensure -Path $destDir | Out-Null

    return $destPath
}