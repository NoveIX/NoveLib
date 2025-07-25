# File: NoveLib\Private\Function\Copy-FileDisplayMode.ps1

function Copy-FileDisplayMode {
    [CmdletBinding()]
    param (
        # Progress bar information
        [System.IO.FileSystemInfo]$File
    )

    # Definition
    [string]$status = $null
    [string]$fileName = $File.Name
    [int]$fileLength = $File.Length

    # Calculate percent
    [double]$averagePercent = (((($Script:CurrentFile_NoveLibFX / $Script:TotalFiles_NoveLibFX) + `
                ($Script:CurrentBytes_NoveLibFX / $Script:TotalBytes_NoveLibFX)) / 2) * 100)

    # Compute and format progress
    [double]$percentComplete = [math]::Round($averagePercent, $DecimalPlaces_NoveLibFX)
    [string]$percentString = "{0:N$Script:DecimalPlaces_NoveLibFX}" -f $percentComplete

    # Convert Bytes in human redable size
    [string]$currentReadable = Convert-ByteToSizeString -Byte $Script:CurrentBytes_NoveLibFX -DecimalPlaces $Script:DecimalPlaces_NoveLibFX
    [string]$totalReadable = Convert-ByteToSizeString -Byte $Script:TotalBytes_NoveLibFX -DecimalPlaces $Script:DecimalPlaces_NoveLibFX

    # Select Display mode
    if ($Script:DisplayMode_NoveLibFX -eq 'FileOnly') { $status = "File $Script:CurrentFile_NoveLibFX of $Script:TotalFiles_NoveLibFX ($percentString `%)" }
    elseif ($Script:DisplayMode_NoveLibFX -eq 'ByteOnly') { $status = "Copied $currentReadable of $totalReadable ($percentString `%)" }
    elseif ($Script:DisplayMode_NoveLibFX -eq 'FileAndByte') { $status = "File $Script:CurrentFile_NoveLibFX of $Script:TotalFiles_NoveLibFX - Copied $currentReadable of $totalReadable ($percentString `%)" }

    # Add file information
    if ($Script:DisplayFileInfo_NoveLibFX) {

        [int]$maxLength = 25
        if ($fileName.Length -gt $maxLength) {
            $fileName = $fileName.Substring(0, $maxLength - 3) + "..."
        }
        $status += " - File: {0,-25} {1,10} B" -f $fileName, $fileLength
    }

    # Show Progress bar
    Write-ProgressBar -Id $Script:Id_NoveLibFX -ParentId $Script:ParentId_NoveLibFX -Activity $Script:Activity_NoveLibFX `
        -Status $status -PercentComplete $percentComplete
}
