function Start-CipherDecrypt {
    <#
    .SYNOPSIS
    Decrypts an encrypted password file using an AES-256 key and returns the result as a SecureString.

    .DESCRIPTION
    This function reads a password string encrypted with PowerShell's AES-based `ConvertFrom-SecureString -Key`, 
    decrypts it using the provided AES-256 key, and returns it as a `System.Security.SecureString`.

    The function expects both the encrypted password file and the binary key file to be located in the same directory,
    or a full path can be provided.

    .PARAMETER Path
    The directory path containing the key file and encrypted password file.

    .PARAMETER Key
    The name of the binary key file (e.g. "AES256.key", "mykey.bin").

    .PARAMETER PWFile
    The name of the encrypted password file (e.g. "secure.txt").

    .OUTPUTS
    System.Security.SecureString

    .EXAMPLE
    $securePass = Start-CipherDecrypt -Path "C:\Keys" -Key "mykey.bin" -PWFile "secure.txt"
    Decrypts the encrypted password in `secure.txt` using `mykey.bin` and returns a SecureString.

    .NOTES
    - The key must be a 256-bit AES key (32 bytes), matching the one used during encryption.
    - If the key or password file is invalid or mismatched, decryption will fail.
    - Output is a SecureString, safe to use with cmdlets requiring credential input.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$PWFile
    )

    $KeyPath = Join-Path $Path $Key
    $PasswordPath = Join-Path $Path $PWFile

    if (-not (Test-Path -Path $KeyPath)) {
        throw "Key file not found: $KeyPath"
    }

    if (-not (Test-Path -Path $PasswordPath)) {
        throw "Password file not found: $PasswordPath"
    }

    try {
        $EncryptedString = Get-Content -Path $PasswordPath -Raw
        $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        $SecurePassword = ConvertTo-SecureString -String $EncryptedString -Key $KeyBytes
    }
    catch {
        throw "Decryption failed. Possibly due to an invalid key or a corrupted password file. $_"
    }

    return $SecurePassword
}