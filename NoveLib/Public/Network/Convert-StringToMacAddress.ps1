# File: NoveLib/Public/Network/Convert-StringToMacAddress.ps1

function Convert-StringToMacAddress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputString,

        [ValidateSet("-", ":")]  # Allow "-", ":"
        [string]$SeparatorChar = "-"
    )

    # Remove all non-hexadecimal characters and convert to uppercase
    $hexOnly = ($InputString -replace '[^0-9A-Fa-f]', '').ToUpper()

    # Validate that the string has exactly 12 hex characters
    if ($hexOnly.Length -ne 12) {
        $sysMsg = "The MAC address must contain exactly 12 hexadecimal characters. "
        $sysMsg += "Provided: $($hexOnly.Length)."
        throw [System.ArgumentException]::new($sysMsg)
    }

    # Split the string into pairs of 2 characters
    $macBytes = for ($i = 0; $i -lt 12; $i += 2) { $hexOnly.Substring($i, 2) }

    # Join with the user-provided separator
    return ($macBytes -join $SeparatorChar)
}