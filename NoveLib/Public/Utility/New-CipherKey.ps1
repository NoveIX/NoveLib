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