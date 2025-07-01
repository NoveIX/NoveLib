function Copy-FileStreamWithProgress {
    [CmdletBinding()]
    param (
        # Source directory to copy from
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Source,

        # Destination directory to copy to
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,

        # Overwrite destination
        [switch]$Force,

        # Progress bar ID and parent (for nested UI)
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # If the file is greater than this value, block copy will be used
        [long]$ChunkThresholdMB = 8,

        # Buffer for block copying
        [long]$BufferSizeMB = 4
    )

    ### Begin
    $funcName = $MyInvocation.MyCommand.Name

    # Validate required helper functions exist
    $requiredFunctions = @(
        'Test-PathIsEmptyOrExist',
        'Get-AllFiles',
        'Test-PathOrCreate',
        'Get-AllBytes',
        'Resolve-Destination',
        'Copy-FileBufferWithProgress',
        'Convert-ByteToReadableString',
        'Write-BarCopyProgress'
    )

    foreach ($func in $requiredFunctions) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw [System.MissingMethodException]::new(
                "$funcName required function '$func' was not found in the current session. Ensure '$func.ps1' is available in NoveLib."
            )
        }
    }

    # Check if the destination path exists and is not empty.
    # If so, and the Force switch is not specified, throw an exception to prevent accidental data loss.
    if (-not (Test-PathIsEmptyOrExist -Path $Destination)) {
        if (-not $Force) {
            throw [System.InvalidOperationException]::new(
                "The path '$Destination' already exists and is not empty. Operation aborted to prevent data loss. Use the 'Force' parameter to overwrite the existing contents."
            )
        }
    }

    # ================================================================ #

    ### Process operation
    # Get all source files recursively
    $files = Get-AllFiles -Path $Source
    if (-not $files -or $files.Count -eq 0) {
        Write-Warning "$funcName no files found in the source directory '$Source'."
        return
    }

    # Ensure destination root directory exists
    Test-PathOrCreate -Path $Destination

    # Initialize progress tracking
    $currentFile = 0
    $totalFiles = $files.Count

    $currentBytes = 0
    $globalCurrentBytes = [ref]$currentBytes
    $totalBytes = Get-AllBytes -Array $files

    $Activity = "Copy in progress..."

    # Parameters used to determine when to use Copy-Buffer
    $ChunkThreshold = $ChunkThresholdMB * 1MB
    $BufferSize = $BufferSizeMB * 1MB

    foreach ($file in $files) {
        # Resolve Destination Path
        $fileDest = Resolve-Destination -Source $Source -Destination $Destination

        # Copy file
        if ($file.Length -ge $ChunkThreshold) {

            # Use Copy-ProgressBuffer for file bigger than ChunkThreshold
            try {
                Copy-FileBufferWithProgress -SourceFile $file.FullName -DestinationFile $fileDest -CurrentFile $currentFile -TotalFiles $totalFiles `
                    -GlobalCurrentBytes $globalCurrentBytes -TotalBytes $totalBytes -BufferSize $BufferSize -Id $Id -ParentId $ParentId
            }
            catch {
                throw [System.IO.IOException]::new(
                    "$funcName failed to copy '$($file.FullName)' to '$destPath'. Error: $($_.Exception.Message)"
                )
            }
            finally {
                # Update counters even if error occurs
                $currentFile++
            }
        }
        else {
            # Use Copy-Item for file Smaller than ChunkThreshold
            try {
                Copy-Item -Path $file.FullName -Destination $fileDest -Force
            }
            catch {
                throw [System.IO.IOException]::new(
                    "$funcName failed to copy '$($file.FullName)' to '$destPath'. Error: $($_.Exception.Message)"
                )
            }
            finally {
                # Update counters even if error occurs
                $currentFile++
                $currentBytes += $file.Length
            }

            # Compute and format progress
            $numericPercent = [math]::Round(($currentBytes / $totalBytes) * 100, 3)
            $percentStr = "{0:N3}" -f $numericPercent

            $currentReadable = Convert-ByteToReadableString -Byte $currentBytes
            $totalReadable = Convert-ByteToReadableString -Byte $totalBytes

            $Status = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentStr `%) - File: $($file.Name) $($file.Length) B"

            # Display progress bar
            Write-BarCopyProgress -Id $Id -ParentId $ParentId -Activity $Activity -Status $Status -PercentComplete $numericPercent
        }
    }

    # Final progress bar cleanup
    Start-Sleep -Milliseconds 250
    Write-BarCopyProgress -Id $Id -ParentId $ParentId -Activity $Activity -Completed
}