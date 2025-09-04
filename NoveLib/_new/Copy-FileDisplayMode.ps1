# File: NoveLib\Private\Function\Copy-FileDisplayMode.ps1

function Copy-FileDisplayMode {
    [CmdletBinding()]
    param (
        # Progress bar information
        [System.IO.FileSystemInfo]$File
    )

    # OPTIMIZED: Pre-calculate common values to avoid repeated calculations
    [double]$fileProgress = $Script:CurrentFile_NoveLibFX / $Script:TotalFiles_NoveLibFX
    [double]$byteProgress = $Script:CurrentBytes_NoveLibFX / $Script:TotalBytes_NoveLibFX
    [double]$averagePercent = (($fileProgress + $byteProgress) / 2) * 100
    [double]$percentComplete = [math]::Round($averagePercent, $Script:DecimalPlaces_NoveLibFX)

    # OPTIMIZED: Use static format string to avoid string interpolation overhead
    [string]$percentString = $percentComplete.ToString("N$($Script:DecimalPlaces_NoveLibFX)")

    # OPTIMIZED: Cache byte size conversions to avoid repeated function calls
    if (-not $Script:CachedTotalReadable_NoveLibFX) {
        $Script:CachedTotalReadable_NoveLibFX = Convert-ByteToSizeString -Byte $Script:TotalBytes_NoveLibFX -DecimalPlaces $Script:DecimalPlaces_NoveLibFX
    }
    [string]$currentReadable = Convert-ByteToSizeString -Byte $Script:CurrentBytes_NoveLibFX -DecimalPlaces $Script:DecimalPlaces_NoveLibFX
    [string]$totalReadable = $Script:CachedTotalReadable_NoveLibFX

    # OPTIMIZED: Use switch statement for better performance than multiple if-elseif
    [string]$status = switch ($Script:DisplayMode_NoveLibFX) {
        'FileOnly' { "File $($Script:CurrentFile_NoveLibFX) of $($Script:TotalFiles_NoveLibFX) ($percentString%)" }
        'ByteOnly' { "Copied $currentReadable of $totalReadable ($percentString%)" }
        'FileAndByte' { "File $($Script:CurrentFile_NoveLibFX) of $($Script:TotalFiles_NoveLibFX) - Copied $currentReadable of $totalReadable ($percentString%)" }
        default { "Processing... ($percentString%)" }
    }

    # OPTIMIZED: Only process file info if needed
    if ($Script:DisplayFileInfo_NoveLibFX) {
        [string]$fileName = $File.Name
        [int]$fileLength = $File.Length
        
        # OPTIMIZED: Use more efficient string truncation
        if ($fileName.Length -gt 25) {
            $fileName = $fileName.Substring(0, 22) + "..."
        }
        $status += " - File: $($fileName.PadRight(25)) $($fileLength.ToString().PadLeft(10)) B"
    }

    # Show Progress bar
    Write-ProgressBar -Id $Script:Id_NoveLibFX -ParentId $Script:ParentId_NoveLibFX -Activity $Script:Activity_NoveLibFX -Status $status -PercentComplete $percentComplete
}
