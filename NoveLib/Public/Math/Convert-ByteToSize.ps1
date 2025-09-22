# File: NoveLib\Public\Math\Convert-ByteToSize.ps1

function Convert-ByteToSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Byte
    )

    # Convert
    if ($Byte -ge 1TB) { $result = ($Byte / 1TB) }
    elseif ($Byte -ge 1GB) { $result = ($Byte / 1GB) }
    elseif ($Byte -ge 1MB) { $result = ($Byte / 1MB) }
    elseif ($Byte -ge 1KB) { $result = ($Byte / 1KB) }
    else { $result = $Byte }

    return $result
}
