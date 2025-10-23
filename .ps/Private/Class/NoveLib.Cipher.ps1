# File: NoveLib\Private\Class\NoveLib.Cipher.ps1

class Cipher {
    # Class properties
    [string]$KeyPath
    [string]$FilePath

    # Constructor
    Cipher(
        [string]$KeyPath,
        [string]$FilePath
    ) {
        $this.KeyPath = $KeyPath
        $this.FilePath = $FilePath
    }
}
