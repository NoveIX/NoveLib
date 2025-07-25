# File: NoveLib\Private\Function\Copy-FileDisplayMode.ps1

function Copy-FileDisplayMode {
    [CmdletBinding()]
    param (
        # Progress bar
        [int]$TotalFiles,
        [double]$TotalBytes,

        # Progress bar information
        [System.IO.FileSystemInfo]$File,
        [string]$DisplayMode,
        [switch]$DisplayFileInfo,
        [int]$DecimalPlaces,
        [string]$Activity,

        # Nested progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null
    )

    # Definition
    [string]$status = $null
    [string]$fileName = $File.Name
    [int]$fileLength = $File.Length

    # Calculate percent
    [double]$averagePercent = (((($globalCurrentFile.Value / $TotalFiles) + ($globalCurrentBytes.Value / $TotalBytes)) / 2) * 100)

    # Compute and format progress
    [double]$percentComplete = [math]::Round($averagePercent, $DecimalPlaces)
    [string]$percentString = "{0:N$DecimalPlaces}" -f $percentComplete

    # Convert Bytes in human redable size
    [string]$currentReadable = Convert-ByteToSizeString -Byte $globalCurrentBytes.Value -DecimalPlaces $DecimalPlaces
    [string]$totalReadable = Convert-ByteToSizeString -Byte $TotalBytes -DecimalPlaces $DecimalPlaces

    # Select Display mode
    if ($DisplayMode -eq 'FileOnly') { $status = "File $($globalCurrentFile.Value) of $TotalFiles ($percentString `%)" }
    elseif ($DisplayMode -eq 'ByteOnly') { $status = "Copied $currentReadable of $totalReadable ($percentString `%)" }
    elseif ($DisplayMode -eq 'FileAndByte') { $status = "File $($globalCurrentFile.Value) of $TotalFiles - Copied $currentReadable of $totalReadable ($percentString `%)" }

    # Add file information
    if ($DisplayFileInfo) {

        [int]$maxLength = 25
        if ($fileName.Length -gt $maxLength) {
            $fileName = $fileName.Substring(0, $maxLength - 3) + "..."
        }
        $status += " - File: {0,-25} {1,10} B" -f $fileName, $fileLength
    }

    # Show Progress bar
    Write-ProgressBar -Id $Id -ParentId $ParentId -Activity $Activity -Status $status -PercentComplete $percentComplete
}
