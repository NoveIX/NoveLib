# File: NoveLib\Public\FileSystem\Copy-FileProgress.ps1

function Copy-FileProgress {
    [CmdletBinding()]
    #region Parameter
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

        # Overwrite files at the destination if they already exist
        [switch]$Force,

        # Specifies the type of progress information to display:
        [ValidateNotNullOrEmpty()]
        [ValidateSet("FileOnly", "ByteOnly", "FileAndByte")]
        [string]$DisplayMode = "FileOnly",

        [switch]$DisplayFileInfo,

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 10)]
        [int]$DecimalPlaces = 2,

        # Use streaming to copy files and continuously update the progress bar
        [switch]$Stream,

        [ValidateSet(2, 4, 8, 16, 32, 64, 128)]
        [int]$MaxFileSizeMB = 8,

        [ValidateSet(1, 2, 4, 8, 16, 32, 64)]
        [int]$BufferSizeMB = 4,

        # Progress bar ID used to track the current progress instance
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null
    )
    #endregion

    # =================================================================================================== #

    #region Name function
    [bool]$fxOrigin = $false
    if (-not $Script:fxName) {
        [string]$Script:fxName = $MyInvocation.MyCommand.Name
        [string]$Script:scrLine = $MyInvocation.ScriptLineNumber
        $fxOrigin = $true
    }
    #endregion

    # =================================================================================================== #

    #region Validate function
    # Validate required helper functions exist
    $requiredFunctions = @(
    )

    foreach ($func in $requiredFunctions) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw [System.MissingMethodException]::new(
                "$funcName required function '$func' was not found in the current session. Ensure '$func.ps1' is available in NoveLib."
            )
        }
    }
    #endregion

    # =================================================================================================== #

    #region Validate IO parameter
    <#     if ((Test-Directory -Mode IsEmptyOrMissing -Path $Source) -or (Test-Directory -Mode IsEmptyOrMissing -Path  $Destination)) {
        throw [System.ArgumentException]::new(
            "Source or Destination path cannot be null or empty."
        )
    }

    # Check if the destination path exists and is not empty.
    # If so, and the Force switch is not specified, throw an exception to prevent accidental data loss.
    if (-not (Test-Directory -Mode IsEmptyOrMissing -Path $Destination)) {
        if (-not $Force) {
            throw [System.InvalidOperationException]::new(
                "The path '$Destination' already exists and is not empty. Operation aborted to prevent data loss. Use the 'Force' parameter to overwrite the existing contents."
            )
        }
    } #>
    #endregion

    # =================================================================================================== #

    #region Process parameter
    # Get all source files recursively
    [array]$files = Get-All -File -Path $Source
    if (-not $files -or ($files.Count -eq 0)) {
        Write-Warning "$fxName no files found in the source directory '$Source'."
        return
    }

    # Ensure destination root directory exists
    Test-Directory -Ensure -Path $Destination | Out-Null

    # Initialize progress tracking
    [int]$currentFile = 0
    [int]$totalFiles = $files.Count

    [double]$currentBytes = 0
    [ref]$globalCurrentBytes = [ref]$currentBytes
    [double]$totalBytes = Get-All -Bytes -Array $files

    if ($Stream) {
        # Parameters used to determine when to use Copy-Buffer
        [long]$MaxFileSize = $MaxFileSizeMB * 1MB
        [long]$BufferSize = $BufferSizeMB * 1MB
    }

    [string]$activity = "Copy in progress..."
    #endregion

    # =================================================================================================== #

    foreach ($file in $files) {
        # Resolve Destination Path And Create
        [string]$fileDest = Copy-FileResolveDestination -File $file -Source $Source -Destination $Destination

        # Copy File
        if (($file.Length -ge $MaxFileSize) -and $Stream) {
            try {
                Copy-FileUseBuffer -SourceFile $file.FullName -DestinationFile $fileDest -CurrentFile $currentFile `
                    -TotalFiles $totalFiles -GlobalCurrentBytes $globalCurrentBytes -TotalBytes $totalBytes `
                    -BufferSize $BufferSize -File $file -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo `
                    -DecimalPlaces $DecimalPlaces -Activity $activity -Id $Id -ParentId $ParentId
            }
            finally { $currentFile++ }
        }
        else {
            try {
                Copy-Item -Path $file.FullName -Destination $fileDest -Force -ErrorAction Stop
            }
            finally {
                $currentFile++
                $currentBytes += $file.Length
            }
        }

        # Display progress bar
        Copy-FileDisplayMode -currentFile $currentFile -totalFiles $totalFiles -currentBytes $currentBytes `
            -totalBytes $totalBytes -File $file -DisplayMode $DisplayMode -DisplayFileInfo:$DisplayFileInfo `
            -DecimalPlaces $DecimalPlaces -Activity $activity -Id $Id -ParentId $ParentId
    }

    # =================================================================================================== #

    #region Function conlusion
    # Final progress bar cleanup
    Start-Sleep -Milliseconds 250
    Write-ProgressBar -Id $Id -ParentId $ParentId -Activity $Activity -Completed

    # =================================================================================================== #

    # Remove script variable
    if ($fxOrigin) {
        Remove-Variable -Name fxName -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name scrLine -Scope Script -ErrorAction SilentlyContinue
    }
    #endregion
}
