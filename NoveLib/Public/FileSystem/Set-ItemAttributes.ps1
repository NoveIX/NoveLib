# File: NoveLib\Public\FileSystem\Set-ItemAttributes.ps1

function Set-ItemAttributes {
    [CmdletBinding()]
    param (
        [switch]$SetHide,
        [switch]$UnsetHide,
        [switch]$ToggleHide,

        [switch]$SetReadOnly,
        [switch]$UnsetReadOnly,
        [switch]$ToggleReadOnly,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # --- Validazione gruppo Hidden ---
    $hiddenCount = @($SetHide, $UnsetHide, $ToggleHide) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
    if ($hiddenCount -gt 1) {
        throw "Specifica solo uno tra -Hide, -Show o -Toggle."
    }

    # --- Validazione gruppo ReadOnly ---
    $readonlyCount = @($SetReadOnly, $UnsetReadOnly, $ToggleReadOnly) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
    if ($readonlyCount -gt 1) {
        throw "Specifica solo uno tra -SetReadOnly, -UnsetReadOnly o -ToggleReadOnly."
    }

    [System.IO.FileSystemInfo]$item = Get-Item -LiteralPath $Path -Force

    # --- Hidden operations ---
    if ($Hide) {
        $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden
    }
    if ($Show) {
        $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
    }
    if ($Toggle) {
        $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::Hidden
    }

    # --- ReadOnly operations ---
    if ($SetReadOnly) {
        $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::ReadOnly
    }
    if ($UnsetReadOnly) {
        $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
    }
    if ($ToggleReadOnly) {
        $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
    }

    return $item.Attributes
}

