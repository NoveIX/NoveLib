# File: NoveLib\Public\Utility\New-CipherKey.ps1

function New-CipherKey {
    param (
        [string]$Path,
        [string]$KeyName,
        [ValidateSet("key", "bin")]
        [string]$Extension
    )

    # Handle key name
    if (-not $KeyName) {
        $KeyName = "AES256"
    }

    # Handle destination path
    if (-not $Path) {
        if (-not $MyInvocation.ScriptName) {
            $Path = Join-Path -Path $PWD -ChildPath "Cred"
        }
        else {
            $Path = Join-Path -Path $PSScriptRoot -ChildPath "Cred"
        }
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        $fullPath = Join-Path -Path $PWD -ChildPath $Path
        $Path = (Resolve-Path -Path $fullPath).Path
    }

    # Ensure the directory exists
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    # Normalize extension
    if (-not $Extension) {
        $Extension = "key"
    }
    if ($Extension.StartsWith(".")) {
        $Extension = $Extension.TrimStart(".")
    }

    # Final key file path
    $KeyFile = "$KeyName.$Extension"
    $KeyPath = Join-Path -Path $Path -ChildPath $KeyFile

    # Generate a 32-byte AES key
    [byte[]]$NewKey = New-Object byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($NewKey)

    # Save key to file
    [System.IO.File]::WriteAllBytes($KeyPath, $NewKey)

    return $KeyPath
}