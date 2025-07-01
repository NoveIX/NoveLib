# File: NoveLib\Public\Network\Convert-CIDRToMask.ps1

function Convert-CIDRToMask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 32)]
        [int]$CIDR
    )

    # Create a binary string with $CIDR ones followed by (32 - $CIDR) zeros
    $binary = '1' * $CIDR + '0' * (32 - $CIDR)

    # Split the 32-bit binary string into 8-bit segments (octets)
    $octets = ($binary -split '(.{8})' | Where-Object { $_ -match '^.{8}$' })

    # Convert each 8-bit binary octet to decimal
    $mask = $octets | ForEach-Object { [Convert]::ToInt32($_, 2) }

    # Join the decimal octets into a dot-separated subnet mask string
    return ($mask -join '.')
}
