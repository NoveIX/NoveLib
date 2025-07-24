# File: NoveLib\Private\Core\New-Directory.ps1

function New-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$Silence,
        [switch]$Force
    )

    $params = @{
        Path     = $Path
        ItemType = 'Directory'
    }

    if ($Force) { $params['Force'] = $true }

    $result = New-Item @params

    if (-not $Silence) {
        return $result
    }
}
