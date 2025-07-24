# File: NoveLib\Public\FileSystem\Set-ItemVisibility.ps1

function Set-ItemVisibility {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Hide")]
        [switch]$Hide,

        [Parameter(Mandatory = $true, ParameterSetName = "Show")]
        [switch]$Show,

        [Parameter(Mandatory = $true, ParameterSetName = "Toggle")]
        [switch]$Toggle,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    [System.IO.FileSystemInfo]$item = Get-Item -LiteralPath $Path -Force

    if ($Hide) {
        return $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden
    }
    elseif ($Show) {
        return $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
    }
    elseif ($Toggle) {
        return $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::Hidden
    }
}
