#file: NoveLib\Private\Core\Test-String.ps1

function Test-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("IsNullOrEmpty")]
        [string]$Mode,

        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    switch ($Mode) {
        "IsNullOrEmpty" {
            return [string]::IsNullOrEmpty($InputString)
        }
    }
}
