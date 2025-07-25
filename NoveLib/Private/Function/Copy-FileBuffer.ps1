# File: NoveLib/Private/Function/Copy-FileBuffer.ps1

function Copy-FileBuffer {
    [CmdletBinding()]
    param(
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$SourceFile,

        [Parameter(Mandatory = $true)]
        [string]$DestinationFile,

        # Buffer
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
        [System.IO.FileSystemInfo]$File,

        [Parameter(Mandatory = $true)]
        [string]$DisplayMode,

        [Parameter(Mandatory = $true)]
        [switch]$DisplayFileInfo,

        [Parameter(Mandatory = $true)]
        [int]$DecimalPlaces,

        [Parameter(Mandatory = $true)]
        [string]$Activity,

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

            # Display progress bar
            Copy-FileDisplayMode -CurrentFile $GlobalCurrentFile.Value -TotalFiles $TotalFiles `
                -CurrentBytes $GlobalCurrentBytes.Value -TotalBytes $TotalBytes -File $file `
                -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo -DecimalPlaces $DecimalPlaces `
                -Activity $Activity -Id $Id -ParentId $ParentId
        }
    }
    finally {
        $sourceStream.Close()
        $destStream.Close()
    }
}
