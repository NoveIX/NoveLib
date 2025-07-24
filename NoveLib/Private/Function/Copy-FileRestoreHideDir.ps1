#File: NoveLib\Private\Function\Copy-FileRestoreHideDir.ps1

function Copy-FileRestoreHideDir {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $hide = Get-All -Dir -Path $Source
}