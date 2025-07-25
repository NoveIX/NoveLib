# File: NoveLib/Private/Function/Copy-FileBuffer.ps1

function Copy-FileBuffer {
    [CmdletBinding()]
    param(
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$SourceFile,

        [Parameter(Mandatory = $true)]
        [string]$DestinationFile,

        # Progress bar information
        [Parameter(Mandatory = $true)]
        [int]$CurrentFile,

        [Parameter(Mandatory = $true)]
        [int]$TotalFiles,

        [Parameter(Mandatory = $true)]
        [ref]$GlobalCurrentBytes,

        [Parameter(Mandatory = $true)]
        [long]$TotalBytes,

        # Buffer
        [Parameter(Mandatory = $true)]
        [long]$BufferSize,

        # Progress bar
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$File,

        [Parameter(Mandatory = $true)]
        [ValidateSet("FileOnly", "ByteOnly", "FileAndByte")]
        [string]$DisplayMode,

        [Parameter(Mandatory = $true)]
        [switch]$DisplayFileInfo,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 10)]
        [int]$DecimalPlaces,

        [Parameter(Mandatory = $true)]
        [string]$activity,

        # Nested progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null
    )

    # Create object buffer
    $buffer = New-Object byte[] $BufferSize

    # Open read/write stream
    $sourceStream = [System.IO.File]::OpenRead($SourceFile)
    $destStream = [System.IO.File]::Create($DestinationFile)

    try {
        while (($bytesRead = $sourceStream.Read($buffer, 0, $BufferSize)) -gt 0) {
            # Write the current buffer chunk to the destination stream
            $destStream.Write($buffer, 0, $bytesRead)

            # Update the global counter for the total bytes copied so far
            $globalCurrentBytes.Value += $bytesRead

            Copy-FileDisplayMode -currentFile $currentFile -totalFiles $totalFiles -currentBytes $globalCurrentBytes.Value `
                -totalBytes $totalBytes -File $file -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo `
                -DecimalPlaces $DecimalPlaces -Activity $activity -Id $Id -ParentId $ParentId
        }
    }
    finally {
        $sourceStream.Close()
        $destStream.Close()
    }
}
