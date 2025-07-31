# File: NoveLib\Public\Utility\Invoke-DecryptSecureString.ps1

function Invoke-DecryptSecureString {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring]$SecureString
    )

    # Decript secure string with .NET
    $ClearPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    )

    return $ClearPassword
}