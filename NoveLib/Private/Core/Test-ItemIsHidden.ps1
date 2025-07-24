# File: NoveLib\Private\Function\Test-ItemIsHidden.ps1

function Test-ItemIsHidden {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path  # The exact path of the directory
    )

    # Retrieve the directory item
    $item = Get-Item -LiteralPath $Path -Force

    # Return True if the directory is hidden, False otherwise
    return ($item.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0
}
