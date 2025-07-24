# File: NoveLib\Private\Core\Test-Directory.ps1

function Test-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Exists")]
        [switch]$Exists,

        [Parameter(Mandatory = $true, ParameterSetName = "Ensure")]
        [switch]$Ensure,

        [Parameter(Mandatory = $true, ParameterSetName = "IsEmptyOrMissing")]
        [switch]$IsEmptyOrMissing,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $params = @{
        LiteralPath = $Path
        PathType    = 'Container'
    }

    if ($Exists) { return Test-Path @params }

    elseif ($Ensure) {
        if (-not (Test-Path @params)) {
            New-Directory -Path $Path -Silence -Force
            return $true
        }
        return $false
    }

    elseif ($IsEmptyOrMissing) {
        if (-not (Test-Path @params)) { return $true }
        else {
            $items = Get-ChildItem -LiteralPath $Path -Force
            return ($items.Count -eq 0)
        }
    }
}
