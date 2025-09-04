# File: NoveLib\Private\Class\NoveLib.Cipher.ps1

class Cipher {
    # Class properties (e.g., [string]$KeyPath, etc.)
    [string]$KeyPath
    [string]$FilePath

    # Constructor to initialize the log setting object
    Cipher(
        [string]$KeyPath,
        [string]$FilePath
    ) {
        $this.KeyPath = $KeyPath
        $this.FilePath = $FilePath
    }

    # Additional constructors or methods can be added here
}
