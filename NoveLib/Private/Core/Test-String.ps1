#file: NoveLib\Private\Core\Test-String.ps1

function Test-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'IsNullOrEmpty')]
        [switch]$IsNullOrEmpty,

        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    if ($IsNullOrEmpty) { return [string]::IsNullOrEmpty($InputString) }
}

