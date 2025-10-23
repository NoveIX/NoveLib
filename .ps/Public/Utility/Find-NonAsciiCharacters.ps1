# File: NoveLib\Public\Utility\Find-NonAsciiCharacters.ps1

function Find-NonAsciiCharacters {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )

    # Get file content
    $lines = Get-Content -Path $Path
    $lineNumber = 0

    # For each line check every char
    foreach ($line in $lines) {
        $lineNumber++
        $chars = $line.ToCharArray()
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $char = $chars[$i]
            if ([int][char]$char -gt 127) {
                Write-Host "Riga $lineNumber, posizione $($i + 1): '$char' (codice: $([int][char]$char))"
            }
        }
    }
}