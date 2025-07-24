# File: NoveLib\Private\Core\Get-All.ps1

function Get-All {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Files', 'Dir', 'Hide', 'ReadOnly', 'Bytes')]
        [string]$Mode,

        [Parameter(Mandatory = $true, ParameterSetName = 'Files', 'Dir', 'Hide', 'ReadOnly')]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'Bytes')]
        [object[]]$Array
    )

    switch ($Mode) {
        'Files' {
            if ($Path) {
                return Get-ChildItem -LiteralPath $Path -Recurse -File -Force
            }
            throw "Path is required when Mode is 'Files'."
        }
        'Dir' {
            if ($Path) {
                return Get-ChildItem -LiteralPath $Path -Recurse -Directory -Force
            }
            throw "Path is required when Mode is 'Files'."
        }
        'Hide' {
            if ($Path) {
                return Get-ChildItem -LiteralPath $Path -Recurse -Hidden -Force
            }
            throw "Path is required when Mode is 'Files'."
        }
        'ReadOnly' {
            if ($Path) {
                return Get-ChildItem -LiteralPath $Path -Recurse -ReadOnly -Force
            }
            throw "Path is required when Mode is 'Files'."
        }
        'Bytes' {
            if ($Array) {
                return ($Array | Measure-Object -Property Length -Sum).Sum
            }
            throw "Array is required when Mode is 'Bytes'."
        }
    }
}
