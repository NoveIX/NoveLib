# File: NoveLib\Public\Utility\Invoke-CipherDecrypt.ps1
function Invoke-CipherDecrypt {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [Parameter(Mandatory = $true)]
        [string]$KeyPath,
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [Parameter(Mandatory = $true)]
        [string]$PWFilePath
    )

    # Resolve path key
    $KeyPath = Resolve-Path -Path $KeyPath
    $PWFilePath = Resolve-Path -Path $PWFilePath

    # Decript passoword
    try {
        $EncryptedString = Get-Content -Path $PWFilePath -Raw
        $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        $SecurePassword = ConvertTo-SecureString -String $EncryptedString -Key $KeyBytes
    }
    catch {
        throw "Decryption failed. Possibly due to an invalid key or a corrupted password file. $_"
    }

    return $SecurePassword
}