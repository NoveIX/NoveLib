# File: NoveLib\Private\Core\New-GuidString.ps1

function New-GuidString {
    [CmdletBinding()]
    param ()

    return [guid]::NewGuid().ToString()
}
