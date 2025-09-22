# File: NoveLib\Public\Utility\Invoke-DecryptSecureString.ps1

function Invoke-DecryptSecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [securestring]$SecureString
    )

    # Decript secure string with .NET
    $ClearString = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    )

    return $ClearString
}