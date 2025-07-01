function Start-CipherEncrypt {
    <#
    .SYNOPSIS
    Encrypts a password input using an AES key and stores it in a file.
        Alias: CipherEncrypt

    .DESCRIPTION
    Prompts the user to enter a plaintext password.  
    The password is then converted to a SecureString, encrypted using the AES key provided,  
    and saved to a file in the specified path.  
    The key must be a binary file containing 16, 24, or 32 bytes (AES-128/192/256).

    Logging is supported via Write-Log functions from the NoveLib module.

    .PARAMETER Path
    The folder where the key file is located and where the encrypted password file will be saved.

    .PARAMETER Key
    The file name of the AES key (binary file) used for encryption.

    .PARAMETER PWFile
    The output file name to store the encrypted password. Defaults to "Password".

    .EXAMPLE
    Start-CipherEncrypt -Path "C:\Keys" -Key "mykey.bin" -PWFile "secure.txt"

    .NOTES
    Ensure the key file exists and contains 16, 24, or 32 bytes.  
    Dependencies: NoveLib (for logging functions)
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [string]$PWFile = "Password"
    )

    # Resolve absolute path
    if (-not ([System.IO.Path]::IsPathRooted($Path))) { 
        $Path = Join-Path -Path $PWD -ChildPath $Path
        Write-LogDebug -Message "Resolved relative path: $Path"
    }
    else {
        Write-LogDebug -Message "Using absolute path: $Path"
    }

    $KeyPath = Join-Path -Path $Path -ChildPath $Key
    Write-LogTrace -Message "Key path: $KeyPath"

    $PasswordPath = Join-Path -Path $Path -ChildPath $PWFile
    Write-LogTrace -Message "Password path: $PasswordPath"

    # Validate key file existence
    if (-not (Test-Path -Path $KeyPath)) {
        Write-LogFail -Message "Key file not found: $KeyPath"
        throw "Encryption key file not found at path: $KeyPath"
    }

    # Validate key length
    $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
    if ($KeyBytes.Length -notin 32) {
        Write-LogFail -Message "Invalid key length: $($KeyBytes.Length) bytes. Must be 32."
        throw "AES key must be 32 bytes in length. Found $($KeyBytes.Length)."
    }

    try {
        Read-Host "Password" |
        ConvertTo-SecureString -AsPlainText -Force |
        ConvertFrom-SecureString -Key $KeyBytes |
        Out-File -FilePath $PasswordPath -Encoding UTF8

        Write-LogDebug -Message "Password encrypted and saved to: $PasswordPath"
    }
    catch {
        Write-LogException -ErrorRecord $_ -Prefix "Encrypt"
        throw "Encryption error: $_"
    }
}