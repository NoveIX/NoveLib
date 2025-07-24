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

    switch ($PSCmdlet.ParameterSetName) {

        'Exists' {
            return Test-Path -LiteralPath $Path -PathType Container
        }

        'Ensure' {
            if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
                New-Directory -Path $Path -Silence -Force
                return $true
            }
            return $false
        }

        'IsEmptyOrMissing' {
            if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
                return $true
            }

            $items = Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue
            return ($items.Count -eq 0)
        }
    }
}
