# File: NoveLib\Private\Core\New-Directory.ps1

function New-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$Silence,
        [switch]$Force
    )

    if ($Silence) {
        New-Item -Path $Path -ItemType Directory | Out-Null
    }
    elseif ($Force) {
        New-Item -Path $Path -ItemType Directory -Force
    }
    elseif ($Silence -and $Force) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
    else {
        New-Item -Path $Path -ItemType Directory
    }
}
