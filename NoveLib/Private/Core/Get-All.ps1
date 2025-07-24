# File: NoveLib\Private\Core\Get-All.ps1

function Get-All {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Files")]
        [switch]$File,

        [Parameter(Mandatory = $true, ParameterSetName = "Dir")]
        [switch]$Dir,

        [Parameter(ParameterSetName = "Files")]
        [Parameter(ParameterSetName = "Dir")]
        [switch]$Hide,

        [Parameter(ParameterSetName = "Files")]
        [Parameter(ParameterSetName = "Dir")]
        [switch]$ReadOnly,

        [Parameter(Mandatory = $true, ParameterSetName = "Bytes")]
        [switch]$Bytes,

        [Parameter(Mandatory = $true, ParameterSetName = "Files")]
        [Parameter(Mandatory = $true, ParameterSetName = "Dir")]
        [Parameter(Mandatory = $true, ParameterSetName = "IOFile")]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "Bytes")]
        [object[]]$Array
    )

    $arguments = @{
        LiteralPath = $Path
        Recurse     = $true
        Force       = $true
    }

    if ($File) { $arguments['File'] = $true }
    if ($Dir) { $arguments['Directory'] = $true }
    if ($Hide) { $arguments['Hidden'] = $true }
    if ($ReadOnly) { $arguments['ReadOnly'] = $true }

    if ($PSCmdlet.ParameterSetName -eq "IOFile") {
        try {
            return Get-ChildItem @arguments
        }
        catch {
            return Get-ChildItem -LiteralPath $Path -Recurse -Force | Where-Object {
                ($Hide -and ($_.Attributes -band [System.IO.FileAttributes]::Hidden)) -or
                ($ReadOnly -and ($_.Attributes -band [System.IO.FileAttributes]::ReadOnly))
            }
        }
    }
    elseif ($Bytes) {
        return ($Array | Measure-Object -Property Length -Sum).Sum
    }
}
