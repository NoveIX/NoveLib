# File: NoveLib\Private\Core\Get-All.ps1

function Get-All {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Files", "Bytes")]
        [string]$Mode,

        [Parameter(Mandatory = $true, ParameterSetName = 'Files')]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'Bytes')]
        [object[]]$Array
    )

    switch ($Mode) {
        "Files" {
            if (-not $Path) {
                throw "Path is required when Mode is 'Files'."
            }
            return Get-ChildItem -LiteralPath $Path -Recurse -File -Force
        }
        "Bytes" {
            if (-not $Array) {
                throw "Array is required when Mode is 'Bytes'."
            }
            return ($Array | Measure-Object -Property Length -Sum).Sum
        }
    }
}
