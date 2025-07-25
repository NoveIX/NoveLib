# File: NoveLib\Private\Function\Copy-FileItem.ps1

function Copy-FileItem {
    [CmdletBinding()]
    param (
        # Parameter
        [Parameter(Mandatory = $true)]
        [object[]]$Files,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # Steam
        [Parameter(Mandatory = $true)]
        [switch]$Stream,

        [Parameter(Mandatory = $true)]
        [int]$MaxFileSize,

        [Parameter(Mandatory = $true)]
        [int]$BufferSize,

        # Progress bar
        [Parameter(Mandatory = $true)]
        [int]$CurrentFile,

        [Parameter(Mandatory = $true)]
        [int]$TotalFiles,

        [Parameter(Mandatory = $true)]
        [double]$CurrentBytes,

        [Parameter(Mandatory = $true)]
        [double]$TotalBytes,

        # Progress bar information
        [Parameter(Mandatory = $true)]
        [string]$DisplayMode,

        [Parameter(Mandatory = $true)]
        [switch]$DisplayFileInfo,

        [Parameter(Mandatory = $true)]
        [int]$DecimalPlaces,

        # Nested progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null
    )

    [string]$activity = "Copy in progress..."
    foreach ($file in $files) {
        # Resolve Destination Path And Create
        [string]$fileDest = Copy-FileResolveDestination -File $file -Source $Source -Destination $Destination -Ensure

        # Copy File
        if (($file.Length -ge $MaxFileSize) -and $Stream) {
            try {
                Copy-FileBuffer -SourceFile $file.FullName -DestinationFile $fileDest -BufferSize  $BufferSize `
                    -CurrentFile $GlobalCurrentFile.Value -TotalFiles $TotalFiles -CurrentBytes $GlobalCurrentBytes.Value `
                    -TotalBytes $TotalBytes -File $file -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo `
                    -DecimalPlaces $DecimalPlaces -Activity $Activity -Id $Id -ParentId $ParentId
            }
            finally {
                $GlobalCurrentFile.Value++
            }
        }
        else {
            try {
                Copy-Item -Path $file.FullName -Destination $fileDest -Force -ErrorAction Stop
            }
            finally {
                $GlobalCurrentFile.Value++
                $globalCurrentBytes.Value += $file.Length
            }
        }

        # Display progress bar
        Copy-FileDisplayMode -CurrentFile $GlobalCurrentFile.Value -TotalFiles $TotalFiles `
            -CurrentBytes $GlobalCurrentBytes.Value -TotalBytes $TotalBytes -File $file `
            -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo -DecimalPlaces $DecimalPlaces `
            -Activity $activity -Id $Id -ParentId $ParentId
    }
}