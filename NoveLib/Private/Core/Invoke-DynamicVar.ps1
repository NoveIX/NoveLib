# File: NoveLib\Private\Core\Invoke-DynamicVar.ps1

function Invoke-DynamicVar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [object]$Value,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet('Script', 'Global')]
        [string]$Scope,

        [switch]$Exit
    )

    if ($PSBoundParameters.ContainsKey('Value')) {
        Set-Variable -Name $Name -Value $Value -Scope $Scope -Force
        if ($Exit) {
            return $null
        }
    }

    if (Get-Variable -Name $Name -Scope Script -ErrorAction SilentlyContinue) {
        return (Get-Variable -Name $Name -Scope $Scope).Value
    }
    else {
        return $null
    }
}
