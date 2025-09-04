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

    # OPTIMIZED: Use FileStream with optimized buffer settings
    $sourceStream = $null
    $destStream = $null
    
    try {
        # OPTIMIZED: Use FileStream constructor with buffer size and sequential access hint
        $sourceStream = [System.IO.FileStream]::new(
            $SourceFile, 
            [System.IO.FileMode]::Open, 
            [System.IO.FileAccess]::Read, 
            [System.IO.FileShare]::Read, 
            $BufferSize,
            [System.IO.FileOptions]::SequentialScan
        )
        
        $destStream = [System.IO.FileStream]::new(
            $DestinationFile, 
            [System.IO.FileMode]::Create, 
            [System.IO.FileAccess]::Write, 
            [System.IO.FileShare]::None, 
            $BufferSize,
            [System.IO.FileOptions]::SequentialScan
        )

        # OPTIMIZED: Create buffer once outside loop
        $buffer = [byte[]]::new($BufferSize)
        $progressUpdateCounter = 0
        $progressUpdateInterval = [Math]::Max(1, ($File.Length / $BufferSize / 100)) # Update progress ~100 times

        while (($bytesRead = $sourceStream.Read($buffer, 0, $BufferSize)) -gt 0) {
            # Write the current buffer chunk to the destination stream
            $destStream.Write($buffer, 0, $bytesRead)

            # Update the global counter for the total bytes copied so far
            $Script:CurrentBytes_NoveLibFX += $bytesRead

            # OPTIMIZED: Reduce progress bar updates for better performance
            $progressUpdateCounter++
            if ($progressUpdateCounter -ge $progressUpdateInterval) {
                Copy-FileDisplayMode -File $File
                $progressUpdateCounter = 0
            }
        }
        
        # Final progress update
        Copy-FileDisplayMode -File $File
    }
    finally {
        if ($sourceStream) { $sourceStream.Dispose() }
        if ($destStream) { $destStream.Dispose() }
    }
}
