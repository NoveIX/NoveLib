# File: NoveLib\Public\FileSystem\Set-ItemAttributes.ps1

function Set-ItemAttributes {
    [CmdletBinding()]
    param (
        [switch]$SetHide,
        [switch]$RemoveHide,
        [switch]$ToggleHide,

        [switch]$SetReadOnly,
        [switch]$RemoveReadOnly,
        [switch]$ToggleReadOnly,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # =================================================================================================== #

    #### Handle parameter

    # --- Hidden group validation ---
    $hiddenCount = @($SetHide, $RemoveHide, $ToggleHide) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
    if ($hiddenCount -gt 1) {
        $sysThrMsg = "Specify only one of -Hide, -Show, or -Toggle."
        throw [System.ArgumentException]::new($sysThrMsg)
    }

    # --- ReadOnly group validation ---
    $readonlyCount = @($SetReadOnly, $RemoveReadOnly, $ToggleReadOnly) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
    if ($readonlyCount -gt 1) {
        $sysThrMsg = "Specify only one of -SetReadOnly, -RemoveReadOnly, or -ToggleReadOnly."
        throw [System.ArgumentException]::new($sysThrMsg)
    }

    # =================================================================================================== #

    #### Set attribute

    [System.IO.FileSystemInfo]$item = Get-Item -LiteralPath $Path -Force

    # --- Hidden operations ---
    if ($SetHide) { $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden }
    if ($RemoveHide) { $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden) }
    if ($ToggleHide) { $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::Hidden }

    # --- ReadOnly operations ---
    if ($SetReadOnly) { $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::ReadOnly }
    if ($RemoveReadOnly) { $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly) }
    if ($ToggleReadOnly) { $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly }
}

