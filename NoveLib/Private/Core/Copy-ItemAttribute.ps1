# File: NoveLib\Private\Core\Copy-ItemAttribute.ps1

function Copy-ItemAttribute {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Il percorso sorgente '$Source' non esiste."
    }
    if (-not (Test-Path -LiteralPath $Destination)) {
        throw "Il percorso di destinazione '$Destination' non esiste."
    }

    [System.IO.FileSystemInfo]$sourceItem = Get-Item -LiteralPath $Source -Force
    [System.IO.FileSystemInfo]$destinationItem = Get-Item -LiteralPath $Destination -Force

    if ($sourceItem.PSIsContainer -ne $destinationItem.PSIsContainer) {
        throw "Source e destination devono essere dello stesso tipo (entrambi file o entrambi cartelle)."
    }

    [System.IO.File]::SetAttributes($destinationItem.FullName, $sourceItem.Attributes)
    if ($destinationItem.PSIsContainer) {
        [System.IO.Directory]::SetAttributes($destinationItem.FullName, $sourceItem.Attributes)
    }
    else {
        [System.IO.File]::SetAttributes($destinationItem.FullName, $sourceItem.Attributes)
    }

}
