# File: NoveLib\Private\Function\Copy-FileItem.ps1

function Copy-FileItem {
    [CmdletBinding()]
    param (
        # Parameter
        [Parameter(Mandatory = $true)]
        [object[]]$Files,

        # Steam
        [Parameter(Mandatory = $true)]
        [switch]$Stream,
        [Parameter(Mandatory = $true)]
        [int]$MaxFileSize,
        [Parameter(Mandatory = $true)]
        [int]$BufferSize
    )

    # OPTIMIZED: Pre-calculate source and destination for better performance
    [string]$sourceBase = $Script:Source_NoveLibFX
    [string]$destBase = $Script:Destination_NoveLibFX
    [int]$sourceBaseLength = $sourceBase.Length

    foreach ($file in $files) {
        try {
            # OPTIMIZED: Resolve Destination Path And Create with error handling
            [string]$fileDest = Copy-FileResolveDestination -File $file -Source $sourceBase -Destination $destBase -Ensure

            # OPTIMIZED: Use file length comparison more efficiently
            [long]$fileLength = $file.Length
            [bool]$useBufferedCopy = $Stream -and ($fileLength -ge $MaxFileSize)

            # Copy File with optimized logic
            if ($useBufferedCopy) {
                Copy-FileBuffer -SourceFile $file.FullName -DestinationFile $fileDest -BufferSize $BufferSize -File $file
            }
            else {
                # OPTIMIZED: Use more efficient copy method for small files
                [System.IO.File]::Copy($file.FullName, $fileDest, $true)
                $Script:CurrentBytes_NoveLibFX += $fileLength
            }
        }
        catch {
            Write-Warning "Failed to copy file '$($file.FullName)': $($_.Exception.Message)"
            # Continue with next file instead of stopping
        }
        finally {
            $Script:CurrentFile_NoveLibFX++
        }

        # OPTIMIZED: Display progress bar less frequently for better performance
        if (($Script:CurrentFile_NoveLibFX % 10) -eq 0 -or $Script:CurrentFile_NoveLibFX -eq $Script:TotalFiles_NoveLibFX) {
            Copy-FileDisplayMode -File $file
        }
    }
}
