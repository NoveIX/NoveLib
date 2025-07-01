#region Key
function New-CipherKey {
    <#
    .SYNOPSIS
    Generates a new AES-256 (32-byte) encryption key and saves it as a binary file.
    Alias: CipherKey

    .DESCRIPTION
    This function creates a cryptographically secure AES-256 key using .NET's RNGCryptoServiceProvider.  
    It allows specifying the key file name, extension, and destination directory.  
    Relative paths are automatically resolved. If the target folder doesn't exist, it will be created.

    The key is saved in binary format, suitable for secure cryptographic operations.

    Logging is supported through custom Write-Log functions from the NoveLib module.

    .PARAMETER Name
    Base name for the key file. Defaults to "AES256".

    .PARAMETER Extension
    File extension for the key file (e.g. "bin", "key"). Defaults to "key".  
    If a dot (e.g. ".bin") is provided, it will be normalized.

    .PARAMETER Path
    Target directory where the key file will be saved.  
    - If omitted and running from terminal: uses `.\Cred`
    - If running from script: uses `$PSScriptRoot\Cred`

    .EXAMPLE
    New-CipherKey -Path "C:\Keys" -Name "MyKey" -Extension "bin"
    → Creates a 256-bit AES key and saves it as `C:\Keys\MyKey.bin`

    .EXAMPLE
    New-CipherKey
    → Saves `AES256.key` in `.\Cred` (or script folder if inside script)

    .NOTES
    The output file contains a raw 32-byte key in binary format.  
    Protect this file carefully and never share it unencrypted.
    Module dependency: NoveLib (for logging)
    #>

    param (
        [string]$Name,
        [ValidateSet("key", "bin")]
        [string]$Extension,
        [string]$Path
    )

    if (-not $Name) { $Name = "AES256" }

    # Handle destination path
    if (-not $Path) {
        if (-not $MyInvocation.ScriptName) {
            $Path = Join-Path -Path $PWD -ChildPath "Cred"
            Write-LogDebug -Message "New-CipherKey called from terminal. Path: $Path"
        }
        else {
            $Path = Join-Path -Path $PSScriptRoot -ChildPath "Cred"
            Write-LogDebug -Message "New-CipherKey called from script. Path: $Path"
        }
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        $Path = Join-Path -Path $PWD -ChildPath $Path
        Write-LogDebug -Message "Resolved relative path: $Path"
    }
    else {
        Write-LogDebug -Message "Using absolute path: $Path"
    }

    # Ensure the directory exists
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-LogDebug -Message "Directory created: $Path"
    }

    # Normalize extension
    if (-not $Extension) { $Extension = "key" }
    if ($Extension.StartsWith(".")) { $Extension = $Extension.TrimStart(".") }

    # Final key file path
    $KeyFileName = "$Name.$Extension"
    Write-LogTrace -Message "Key file name: $KeyFileName"
    $KeyPath = Join-Path -Path $Path -ChildPath $KeyFileName
    Write-LogTrace -Message "Full key path: $KeyPath"

    # Generate a 32-byte AES key
    [byte[]]$NewKey = New-Object byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($NewKey)
    Write-LogTrace -Message "Generated AES key bytes: $($NewKey -join ',')"

    # Save key to file
    [System.IO.File]::WriteAllBytes($KeyPath, $NewKey)
    Write-LogTrace -Message "Key saved to: $KeyPath"
}

#endregion

################################################################################################################################

#region Encrypt
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

#endregion

################################################################################################################################

#region Decrypt
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

#endregion

################################################################################################################################

#region Password Clear
function Write-CipherPasswordClear {
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
#endregion

################################################################

# Set Alias
Set-Alias -Name "CipherKey" -Value New-CipherKey
Set-Alias -Name "CipherEncrypt" -Value Start-CipherEncrypt
Set-Alias -Name "CipherDecrypt" -Value Start-CipherDecrypt
Set-Alias -Name "CipherPasswordClear" -Value Write-CipherPasswordClear

# Export functions and aliases
Export-ModuleMember -Function @(
    "New-CipherKey",
    "Start-CipherEncrypt",
    "Start-CipherDecrypt",
    "Write-CipherPasswordClear"
) -Alias @(
    "CipherKey",
    "CipherEncrypt",
    "CipherDecrypt",
    "CipherPasswordClear"
)