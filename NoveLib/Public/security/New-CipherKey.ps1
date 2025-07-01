# File: NoveLib\Public\security\New-CipherKey.ps1

function New-CipherKey {
    [CmdletBinding()]
    param (
        [string]$Path,
        [string]$KeyName,

        [ValidateSet('key', 'bin')]
        [string]$Extension = 'key',

        [Parameter(ParameterSetName = 'AES')] # AES (Advanced Encryption Standard) mode CBC (Cipher Block Chaining) padding PKCS7.
        [ValidateSet(128, 192, 256)]
        [int]$AESKeySize = 256
    )

    # =======================================================[ Handle path ]======================================================== #

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

    # =====================================================[ Handle Filename ]====================================================== #

    # key name
    switch ($AESKeySize) {
        128 {
            $KeyName = if (-not $KeyName) { "AES128" } else { [System.IO.Path]::GetFileNameWithoutExtension($KeyName) }
            $keyByte = 16
        }
        192 {
            $KeyName = if (-not $KeyName) { "AES192" } else { [System.IO.Path]::GetFileNameWithoutExtension($KeyName) }
            $keyByte = 24
        }
        256 {
            $KeyName = if (-not $KeyName) { "AES256" } else { [System.IO.Path]::GetFileNameWithoutExtension($KeyName) }
            $keyByte = 32
        }
    }

    # Final key file path
    $KeyFile = "$KeyName.$Extension"
    $KeyPath = Join-Path -Path $Path -ChildPath $KeyFile

    # =======================================================[ Generate key ]======================================================= #

    # Generate a AES key
    [byte[]]$NewKey = [byte[]]::new($keyByte)
    if (${PSVersionTable}.PSVersion.Major -ge 7) {
        [System.Security.Cryptography.RandomNumberGenerator]::Fill($NewKey)
    }
    else {
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($NewKey)
    }

    # Save key to file
    if (-not (Test-Path -Path $KeyPath)) { New-Item -Path $KeyPath -ItemType File -Force | Out-Null }
    [System.IO.File]::WriteAllBytes($KeyPath, $NewKey)

    # =====================================================[ Return key file ]====================================================== #

    return $(Get-Item -Path $KeyPath)
}