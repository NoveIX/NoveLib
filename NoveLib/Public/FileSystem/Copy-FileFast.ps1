# File: NoveLib\Public\FileSystem\Copy-FileFast.ps1

function Copy-FileFast {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination
    )

    # Crea la destinazione se non esiste
    if (-not (Test-Path -LiteralPath $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    # Copia ricorsiva con preservazione degli attributi
    $items = Get-ChildItem -Path $Source -Recurse -Force
    foreach ($item in $items) {
        [string]$relativePath = $item.FullName.Substring((Resolve-Path $Source).Path.Length)
        [string]$destPath = Join-Path -Path $Destination -ChildPath $relativePath
        Copy-Item -Path $item.FullName -Destination $destPath -Force
    }
}
