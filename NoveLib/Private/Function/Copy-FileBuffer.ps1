# File: NoveLib/Private/Function/Copy-FileBuffer.ps1

function Copy-FileBuffer {
    [CmdletBinding()]
    param(
        # Transfer Point
        [Parameter(Mandatory = $true)]
        [string]$SourceFile,
        [Parameter(Mandatory = $true)]
        [string]$DestinationFile,

        # Buffer
        [Parameter(Mandatory = $true)]
        [int]$BufferSize,

        # Progress bar information
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$File
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
            $Script:CurrentBytes_NoveLibFX += $bytesRead

            # Display progress bar
            Copy-FileDisplayMode -File $File
        }
    }
    finally {
        $sourceStream.Close()
        $destStream.Close()
    }
}
