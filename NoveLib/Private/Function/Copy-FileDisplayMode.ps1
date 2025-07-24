# File: NoveLib\Private\Function\Copy-FileDisplayMode.ps1

function Copy-FileDisplayMode {
    param (
        [Parameter(Mandatory = $true)]
        [int]$currentFile,

        [Parameter(Mandatory = $true)]
        [int]$totalFiles,

        [Parameter(Mandatory = $true)]
        [double]$currentBytes,

        [Parameter(Mandatory = $true)]
        [double]$totalBytes,

        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$File,

        [Parameter(Mandatory = $true)]
        [ValidateSet("FileOnly", "ByteOnly", "FileAndByte")]
        [string]$DisplayMode,

        [Parameter(Mandatory = $true)]
        [switch]$DisplayFileInfo,

        [ValidateRange(0, 10)]
        [int]$DecimalPlaces,

        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null
    )

    # Definition
    [string]$status = $null
    [string]$fileName = $File.Name
    [int]$fileLength = $File.Length

    # Calculate percent
    [double]$averagePercent = (((($currentFile / $totalFiles) + ($currentBytes / $totalBytes)) / 2) * 100)

    # Compute and format progress
    [double]$percentComplete = [math]::Round($averagePercent, $DecimalPlaces)
    [string]$percentString = "{0:N$DecimalPlaces}" -f $percentComplete

    # Convert Bytes in human redable size
    [string]$currentReadable = Convert-ByteToSizeString -Byte $currentBytes -DecimalPlaces $DecimalPlaces
    [string]$totalReadable = Convert-ByteToSizeString -Byte $totalBytes -DecimalPlaces $DecimalPlaces

    # Select Display mode
    if ($DisplayMode -eq 'FileOnly') { $status = "File $currentFile of $totalFiles ($percentString `%)" }
    elseif ($DisplayMode -eq 'ByteOnly') { $status = "Copied $currentReadable of $totalReadable ($percentString `%)" }
    elseif ($DisplayMode -eq 'FileAndByte') { $status = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentString `%)" }

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
