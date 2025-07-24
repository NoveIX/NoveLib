# File: NoveLib\Private\Core\New-Directory.ps1

function New-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    New-Item -Path $Path -ItemType Directory -Force | Out-Null
}
