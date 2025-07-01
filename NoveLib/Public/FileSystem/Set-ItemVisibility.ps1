# File: NoveLib\Public\FileSystem\Set-ItemVisibility.ps1

function Set-ItemVisibility {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Hide", "Show", "Toggle")]
        [string]$Mode
    )

    try {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    }
    catch {
        throw "Impossibile trovare l'elemento '$Path'. $_"
    }

    $isHidden = ($item.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0

    switch ($Mode) {
        "Hide" {
            if (-not $isHidden) {
                $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
        }
        "Show" {
            if ($isHidden) {
                $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
            }
        }
        "Toggle" {
            $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::Hidden
        }
    }
}
