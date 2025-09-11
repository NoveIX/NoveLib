# File: NoveLib\Public\Utility\New-CipherKey.ps1

function New-CipherKey {
    [CmdletBinding()]
    param (
        [string]$Path,
        [string]$KeyName,

        [ValidateSet("key", "bin")]
        [string]$Extension,

        [Parameter(ParameterSetName = 'PS_AES')] # AES (Advanced Encryption Standard) mode CBC (Cipher Block Chaining) padding PKCS7.
        [ValidateSet(128, 192, 256)]
        [int]$AESKeyLength = 256,

        [switch]$OutNull
    )

    # =================================================================================================== #

    #### Handle path

    # Cred path
    if (-not $Path) {
        # If the script was not started from a file, use the current folder.
        $basePath = if ($MyInvocation.ScriptName) { $PSScriptRoot } else { $PWD }
        $Path = Join-Path -Path $basePath -ChildPath "Cred"
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        # Converts to absolute path if relative
        $Path = (Resolve-Path -Path (Join-Path -Path $PWD -ChildPath $Path)).Path
    }

    # =================================================================================================== #

    #### Ensure Directory

    # Ensure the directory exists
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    # =================================================================================================== #

    ####  Handle Filename

    # key name
    if ($AESKeyLength -eq 128) {
        if (-not $KeyName) { $KeyName = "AES128" }
        $keyByteLength = 16
    }
    elseif ($AESKeyLength -eq 128) {
        if (-not $KeyName) { $KeyName = "AES192" }
        $keyByteLength = 24
    }
    elseif ($AESKeyLength -eq 256) {
        if (-not $KeyName) { $KeyName = "AES256" }
        $keyByteLength = 32
    }

    # Define default key extension if missing
    if (-not $Extension -or [string]::IsNullOrWhiteSpace($Extension) -or $Extension -eq ".") {
        $Extension = "key"
    }
    else {
        $Extension = $Extension.TrimStart(".").ToLower()
        if (-not $Extension) { $Extension = "key" }
    }

    # Final key file path
    $KeyFile = "$KeyName.$Extension"
    $KeyPath = Join-Path -Path $Path -ChildPath $KeyFile

    # =================================================================================================== #

    #### Generate Key

    # Generate a byte AES key
    [byte[]]$NewKey = [byte[]]::new($keyByteLength)
    if (${PSVersionTable}.PSVersion.ToString() -like "5.1*") {
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($NewKey) # PS5
    }
    elseif (${PSVersionTable}.PSVersion.ToString() -like "7*") {
        [System.Security.Cryptography.RandomNumberGenerator]::Fill($NewKey) # PS7
    }

    # Save key to file
    [System.IO.File]::WriteAllBytes($KeyPath, $NewKey)

    # Silence function output
    if ($OutNull) { return }

    return $KeyPath
}