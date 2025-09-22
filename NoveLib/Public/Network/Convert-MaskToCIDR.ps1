# File: NoveLib/Public/Network/Convert-MaskToCIDR.ps1

function Convert-MaskToCIDR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Mask
    )

    # Validate IPv4 dotted-decimal format
    if ($Mask -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
        $sysMsg = "Invalid IPv4 subnet mask format: '$Mask'."
        throw [System.FormatException]::new($sysMsg)
    }

    # Convert each octet to binary and build the full binary string
    $binary = ($Mask.Split('.') | ForEach-Object {
            if ($_ -gt 255 -or $_ -lt 0) {
                $sysMsg = "Octet '$_' is out of range (0-255)."
                throw [System.ArgumentOutOfRangeException]::new($sysMsg)
            }
            [Convert]::ToString([int]$_, 2).PadLeft(8, '0')
        }) -join ''

    # Ensure the mask is contiguous: only leading 1's followed by 0's are valid
    if ($binary -notmatch '^1*0*$') {
        $sysMsg = "Subnet mask is not valid: bits are not contiguous (binary: $binary)."
        throw [System.ArgumentException]::new($sysMsg)
    }

    # Count the number of '1' bits to determine the CIDR prefix length
    return ($binary -replace '0').Length
}
