# File: NoveLib\Private\Core\Test-Directory.ps1

function Test-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Exists", "Ensure", "IsEmptyOrMissing")]
        [string]$Mode,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    switch ($Mode) {
        "Exists" {
            return Test-Path -LiteralPath $Path -PathType Container
        }

        "Ensure" {
            if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
                New-Directory -Path $Path -Silence -Force
                return $true
            }
            return $false
        }

        "IsEmptyOrMissing" {
            if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
                return $true
            }
            $items = Get-ChildItem -LiteralPath $Path -Force
            return ($items.Count -eq 0)
        }
    }
}
