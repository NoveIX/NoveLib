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

        [switch]$CopyEmptyFolder,

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
    # Get all source files recursively - OPTIMIZED: Single call with better error handling
    try {
        [array]$files = Get-All -File -Path $Source
        [array]$dirs = Get-All -Dir -Path $Source
    }
    catch {
        throw [System.IO.DirectoryNotFoundException]::new(
            "Unable to access source directory '$Source': $($_.Exception.Message)"
        )
    }

    if (-not $files -or ($files.Count -eq 0)) {
        Write-Warning "$fxName no files found in the source directory '$Source'."
        return
    }

    # Ensure destination root directory exists
    Test-Directory -Ensure -Path $Destination | Out-Null

    # OPTIMIZED: Pre-calculate values to avoid repeated calculations
    [string]$Script:Source_NoveLibFX = $Source
    [string]$Script:Destination_NoveLibFX = $Destination

    # Initialize progress tracking
    [int]$Script:CurrentFile_NoveLibFX = 0
    [int]$Script:TotalFiles_NoveLibFX = $files.Count + $dirs.Count

    [double]$Script:CurrentBytes_NoveLibFX = 0
    [double]$Script:TotalBytes_NoveLibFX = Get-All -Bytes -Array $files

    # Progress bar information
    [string]$Script:Activity_NoveLibFX = "Copy in progress..."
    [string]$Script:DisplayMode_NoveLibFX = $DisplayMode
    [switch]$Script:DisplayFileInfo_NoveLibFX = $DisplayFileInfo
    [int]$Script:DecimalPlaces_NoveLibFX = $DecimalPlaces

    # OPTIMIZED: Initialize cache for total readable size
    [string]$Script:CachedTotalReadable_NoveLibFX = $null

    # Nested progress bar
    [int]$Script:Id_NoveLibFX = $Id
    [System.Nullable[int]]$Script:ParentId_NoveLibFX = $ParentId

    # OPTIMIZED: Pre-calculate buffer parameters outside conditional
    [long]$maxFileSize = if ($Stream) { $MaxFileSizeMB * 1MB } else { [long]::MaxValue }
    [long]$bufferSize = if ($Stream) { $BufferSizeMB * 1MB } else { 0 }
    #endregion

    # =================================================================================================== #

    #region Copy file
    Copy-FileItem -Files $files -Stream:$Stream -MaxFileSize $maxFileSize -BufferSize $bufferSize
    #endregion

    # =================================================================================================== #

    #region Copy Dir
    Copy-FileDir -Dirs $dirs -CopyEmptyFolder:$CopyEmptyFolder

    # =================================================================================================== #

    #region Function conclusion - OPTIMIZED: Simplified cleanup
    # OPTIMIZED: Batch variable removal without progress bar overhead
    $RemoveScritpFX = @(
        'Source_NoveLibFX',
        'Destination_NoveLibFX',
        'CurrentFile_NoveLibFX',
        'TotalFiles_NoveLibFX',
        'CurrentBytes_NoveLibFX',
        'TotalBytes_NoveLibFX',
        'Activity_NoveLibFX',
        'DisplayMode_NoveLibFX',
        'DisplayFileInfo_NoveLibFX',
        'DecimalPlaces_NoveLibFX',
        'CachedTotalReadable_NoveLibFX',
        'Id_NoveLibFX',
        'ParentId_NoveLibFX'
    )

    # OPTIMIZED: Remove all variables at once without progress tracking
    foreach ($fx in $RemoveScritpFX) {
        Remove-Variable -Name $fx -Scope Script -ErrorAction SilentlyContinue
    }

    # Final progress bar cleanup - OPTIMIZED: Removed unnecessary sleep
    Write-ProgressBar -Id $Id -ParentId $ParentId -Activity "Operation completed" -Completed

    # =================================================================================================== #

    # Remove script variable
    if ($fxOrigin) {
        Remove-Variable -Name fxName -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name scrLine -Scope Script -ErrorAction SilentlyContinue
    }
    #endregion
}
