# File: NoveLib\Private\Core\Get-All.ps1

function Get-All {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Files")]
        [switch]$Files,

        [Parameter(Mandatory = $true, ParameterSetName = "Dir")]
        [switch]$Dir,

        [Parameter(Mandatory = $true, ParameterSetName = "Hide")]
        [switch]$Hide,

        [Parameter(Mandatory = $true, ParameterSetName = "ReadOnly")]
        [switch]$ReadOnly,

        [Parameter(Mandatory = $true, ParameterSetName = "All")]
        [switch]$All,

        [Parameter(Mandatory = $true, ParameterSetName = "Bytes")]
        [switch]$Bytes,

        [Parameter(Mandatory = $true, ParameterSetName = "Files")]
        [Parameter(Mandatory = $true, ParameterSetName = "Dir")]
        [Parameter(Mandatory = $true, ParameterSetName = "Hide")]
        [Parameter(Mandatory = $true, ParameterSetName = "ReadOnly")]
        [Parameter(Mandatory = $true, ParameterSetName = "All")]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "Bytes")]
        [object[]]$Array
    )

    if ($Files) {
        return Get-ChildItem -LiteralPath $Path -Recurse -File -Force
    }
    elseif ($Dir) {
        return Get-ChildItem -LiteralPath $Path -Recurse -Directory -Force
    }
    elseif ($Hide) {
        try {
            return Get-ChildItem -LiteralPath $Path -Recurse -Hidden -Force
        }
        catch {
            return Get-ChildItem -LiteralPath $Path -Recurse -Force |
            Where-Object { $_.Attributes -band [System.IO.FileAttributes]::Hidden }
        }
    }
    elseif ($ReadOnly) {
        try {
            return Get-ChildItem -LiteralPath $Path -Recurse -ReadOnly -Force
        }
        catch {
            return Get-ChildItem -LiteralPath $Path -Recurse -Force |
            Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReadOnly }
        }
    }
    elseif ($All) {
        Get-ChildItem -LiteralPath $Path -Recurse -Force
    }
    elseif ($Bytes) {
        return ($Array | Measure-Object -Property Length -Sum).Sum
    }
}
