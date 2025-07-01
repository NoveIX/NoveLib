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
    $status = $null
    $fileName = $File.Name
    $fileLength = $File.Length

    # Calculate percent
    $averagePercent = (((($currentFile / $totalFiles) + ($currentBytes / $totalBytes)) / 2) * 100)

    # Compute and format progress
    $percentComplete = [math]::Round($averagePercent, $DecimalPlaces)
    $percentString = "{0:N$DecimalPlaces}" -f $percentComplete

    # Convert Bytes in human redable size
    $currentReadable = Convert-ByteToSizeString -Byte $currentBytes -DecimalPlaces $DecimalPlaces
    $totalReadable = Convert-ByteToSizeString -Byte $totalBytes -DecimalPlaces $DecimalPlaces

    # Select Display mode
    switch ($DisplayMode) {
        "FileOnly" { $status = "File $currentFile of $totalFiles ($percentString `%)" }
        "ByteOnly" { $status = "Copied $currentReadable of $totalReadable ($percentString `%)" }
        "FileAndByte" { $status = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentString `%)" }
    }

    # Add file information
    if ($DisplayFileInfo) {

        $maxLength = 25
        if ($fileName.Length -gt $maxLength) {
            $fileName = $fileName.Substring(0, $maxLength - 3) + "..."
        }
        $status += " - File: {0,-25} {1,10} B" -f $fileName, $fileLength
    }

    # Show Progress bar
    Write-ProgressBar -Id $Id -ParentId $ParentId -Activity $Activity -Status $status -PercentComplete $percentComplete
}
