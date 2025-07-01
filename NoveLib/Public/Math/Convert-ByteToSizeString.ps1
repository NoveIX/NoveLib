# File: NoveLib\Public\Math\Convert-ByteToSizeString.ps1

function Convert-ByteToSizeString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Byte,

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 10)]
        [int]$DecimalPlaces = 2
    )

    # Convert
    if ($Byte -ge 1TB) { $result = "{0:N$DecimalPlaces} TB" -f ($Byte / 1TB) }
    elseif ($Byte -ge 1GB) { $result = "{0:N$DecimalPlaces} GB" -f ($Byte / 1GB) }
    elseif ($Byte -ge 1MB) { $result = "{0:N$DecimalPlaces} MB" -f ($Byte / 1MB) }
    elseif ($Byte -ge 1KB) { $result = "{0:N$DecimalPlaces} KB" -f ($Byte / 1KB) }
    else { $result = "$Byte Byte$(if ($Byte -ne 1) { 's' } else { '' })" }

    return $result
}
