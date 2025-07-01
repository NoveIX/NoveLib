function Show-CipherPasswordClear {
    <#
    .SYNOPSIS
    Decrypts and displays the stored password in clear text.

    .DESCRIPTION
    This function uses a stored AES key to decrypt a saved password file and prints the password in plain text.
    It is intended for testing or recovery purposes only.

    .PARAMETER Path
    The directory containing the key and password files.

    .PARAMETER Key
    The name of the AES key file used for decryption.

    .PARAMETER PWFile
    The name of the encrypted password file.

    .EXAMPLE
    Write-CipherPasswordClear -Path "C:\Keys" -Key "mykey.bin" -PWFile "secure.txt"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [Parameter(Mandatory = $true)]
        [string]$PWFile
    )

    #reads the key and password decrypts it and prints it in plain text
    $Decrypted = Start-CipherDecrypt -Directory $Path -Key $Key -PWFile $PWFile
    $ClearPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Decrypted)
    )

    Write-Host "Decrypted password: $ClearPassword"
}