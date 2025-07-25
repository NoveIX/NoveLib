# File: NoveLib\Private\Function\Copy-FileDisplayMode.ps1

function Copy-FileDisplayMode {
    param (
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

        [ValidateRange(0, 10)]
        [int]$DecimalPlaces,

        [Parameter(Mandatory = $true)]
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
    [double]$averagePercent = (((($CurrentFile / $TotalFiles) + ($CurrentBytes / $TotalBytes)) / 2) * 100)

    # Compute and format progress
    [double]$percentComplete = [math]::Round($averagePercent, $DecimalPlaces)
    [string]$percentString = "{0:N$DecimalPlaces}" -f $percentComplete

    # Convert Bytes in human redable size
    [string]$currentReadable = Convert-ByteToSizeString -Byte $CurrentBytes -DecimalPlaces $DecimalPlaces
    [string]$totalReadable = Convert-ByteToSizeString -Byte $TotalBytes -DecimalPlaces $DecimalPlaces

    # Select Display mode
    if ($DisplayMode -eq 'FileOnly') { $status = "File $CurrentFile of $TotalFiles ($percentString `%)" }
    elseif ($DisplayMode -eq 'ByteOnly') { $status = "Copied $currentReadable of $totalReadable ($percentString `%)" }
    elseif ($DisplayMode -eq 'FileAndByte') { $status = "File $CurrentFile of $TotalFiles - Copied $currentReadable of $totalReadable ($percentString `%)" }

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
