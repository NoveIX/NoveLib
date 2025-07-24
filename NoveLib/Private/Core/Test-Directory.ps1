# File: NoveLib\Private\Core\Test-Directory.ps1

function Test-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [switch]$Exists,

        [Parameter(Mandatory = $true)]
        [switch]$Ensure,

        [Parameter(Mandatory = $true)]
        [switch]$IsEmptyOrMissing,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Exists) {
        return Test-Path -LiteralPath $Path -PathType Container
    }
    elseif ($Ensure) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            New-Directory -Path $Path -Silence -Force
            return $true
        }
        return $false
    }
    elseif ($IsEmptyOrMissing) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            return $true
        }
        $items = Get-ChildItem -LiteralPath $Path -Force
        return ($items.Count -eq 0)
    }
}
