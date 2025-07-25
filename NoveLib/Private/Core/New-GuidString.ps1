# File: NoveLib\Private\Core\New-GuidString.ps1

function New-GuidString {
    [CmdletBinding()]
    param (
        [ValidateSet("D", "d", "N", "n", "P", "p", "B", "b", "X", "x")]
        [char]$Mode
    )

    return [guid]::NewGuid().ToString($Mode)
}
