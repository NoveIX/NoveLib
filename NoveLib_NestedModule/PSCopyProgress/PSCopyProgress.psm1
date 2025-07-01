#region Files
function Copy-ProgressFile {
    [CmdletBinding()]
    param (
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [switch]$print,
        [switch]$PrintTime,

        # Extra parameter self defined
        [pscustomobject]$LogSetting = $ProgressFileLogSetting,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO"
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "New-LogSetting"     = "PSWriteLog"
        "Write-LogTrace"     = "PSWriteLog"
        "Write-LogDebug"     = "PSWriteLog"
        "Write-LogWarn"      = "PSWriteLog"
        "Write-LogException" = "PSWriteLog"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    if ($null -eq $LogSetting) {
        $logFilename = "${$FunctionName}Log_$LogMinLevel"
        $logFolder = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )
        $LogSetting = New-LogSetting -Filename $logFilename -Path $logFolder -LogMinLevel $LogMinLevel -DateInLogFile
    }

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start log
    Write-LogDebug -Message "[$FunctionName] Initialization function" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Parmater log
    Write-LogTrace -Message "[$FunctionName] Source: $Source - Destination: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Id: $Id - ParentId: $(if($null -eq $ParentId) {"null"} else {$ParentId})" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Create main destination folder
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-LogDebug -Message "[$FunctionName] Created main destination directory: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Get the list of all files recursively
    $files = Get-ChildItem -Path $Source -Recurse -File
    $PreviewFileNumber = 50
    $preview = $files | Select-Object -First $PreviewFileNumber
    Write-LogTrace -Message "[$FunctionName] Preview of first $PreviewFileNumber files:`n$($preview | Format-Table -AutoSize | Out-String)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTim
        
    $currentFile = 0
    $totalFiles = $files.Count
    Write-LogTrace -Message "[$FunctionName] Total files: $totalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Log before foreach
    Write-LogDebug -Message "[$FunctionName] Starting file copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    foreach ($file in $files) {
        # log White space
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Resolve source and destination path
        $relativePath = $file.FullName.Substring((Resolve-Path $Source).Path.Length)
        $destPath = Join-Path -Path $Destination -ChildPath $relativePath
        Write-LogTrace -Message "[$FunctionName] Relative Source: .$relativePath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogTrace -Message "[$FunctionName] Destination: $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Extract destination dir
        $destDir = Split-Path -Path $destPath -Parent
        Write-LogTrace -Message "[$FunctionName] Extracted destination dir: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Create sub destination folder
        if (-not (Test-Path -Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Write-LogDebug -Message "[$FunctionName] Created sub destination directory: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }

        # Copy item
        try {
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        catch {
            $ErrorRecord = $_
            Write-LogWarn -Message "[$FunctionName] Failed to copy file: $($file.FullName) to $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            Write-LogException -ErrorRecord $ErrorRecord -Prefix $FunctionName -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        finally {
            $currentFile++
        }

        # Update parameter for progress bar
        $numericPercent = [math]::Round(($currentFile / $totalFiles) * 100, 3)
        $percentStr = "{0:N3}" -f $numericPercent

        # Progress bar
        $progressMessage = "File $currentFile of $totalFiles ($percentStr `%) - File: $($file.Name) $($file.Length) B"
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }

        Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Log withe space
    Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Completed copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Sleeping 250 milliseconds" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Start-Sleep -Milliseconds 250

    # Final progress bar reset
    if ($null -eq $ParentId) {
        Write-Progress -Id $Id -Activity "Copy in progress..." -Completed
    }
    else {
        Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Completed
    }

    Write-LogDebug -Message "[$FunctionName] Function terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Byte
function Copy-ProgressByte {
    [CmdletBinding()]
    param (
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [switch]$print,
        [switch]$PrintTime,

        # Extra parameter self defined
        [pscustomobject]$LogSetting = $ProgressFileLogSetting,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO"
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "New-LogSetting"             = "PSWriteLog"
        "Write-LogTrace"             = "PSWriteLog"
        "Write-LogDebug"             = "PSWriteLog"
        "Write-LogWarn"              = "PSWriteLog"
        "Write-LogException"         = "PSWriteLog"
        "Convert-ByteToReadableSize" = "PSConvert"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    if ($null -eq $LogSetting) {
        $logFilename = "${$FunctionName}Log_$LogMinLevel"
        $logFolder = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )
        $LogSetting = New-LogSetting -Filename $logFilename -Path $logFolder -LogMinLevel $LogMinLevel -DateInLogFile
    }

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start log
    Write-LogDebug -Message "[$FunctionName] Initialization function" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Parmater log
    Write-LogTrace -Message "[$FunctionName] Source: $Source - Destination: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Id: $Id - ParentId: $(if($null -eq $ParentId) {"null"} else {$ParentId})" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Create main destination folder
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-LogDebug -Message "[$FunctionName] Created main destination directory: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Get the list of all files recursively
    $files = Get-ChildItem -Path $Source -Recurse -File
    $PreviewFileNumber = 50
    $preview = $files | Select-Object -First $PreviewFileNumber
    Write-LogTrace -Message "[$FunctionName] Preview of first $PreviewFileNumber files:`n$($preview | Format-Table -AutoSize | Out-String)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    
    $totalFiles = $files.Count
    Write-LogTrace -Message "[$FunctionName] Total files: $totalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    
    $currentBytes = 0
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    Write-LogDebug -Message "[$FunctionName] Total bytes: $totalBytes" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Log before foreach
    Write-LogDebug -Message "[$FunctionName] Starting file copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    foreach ($file in $files) {
        # log White space
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Resolve source and destination path
        $relativePath = $file.FullName.Substring((Resolve-Path $Source).Path.Length)
        $destPath = Join-Path -Path $Destination -ChildPath $relativePath
        Write-LogTrace -Message "[$FunctionName] Relative Source: .$relativePath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogTrace -Message "[$FunctionName] Destination: $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Extract destination dir
        $destDir = Split-Path -Path $destPath -Parent
        Write-LogTrace -Message "[$FunctionName] Extracted destination dir: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Create sub destination folder
        if (-not (Test-Path -Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Write-LogDebug -Message "[$FunctionName] Created sub destination directory: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }

        # Copy item
        try {
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        catch {
            $ErrorRecord = $_
            Write-LogWarn -Message "[$FunctionName] Failed to copy file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            Write-LogException -ErrorRecord $ErrorRecord -Prefix $FunctionName -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        finally {
            $currentBytes += $file.Length
        }

        # Update parameter for progress bar
        $numericPercent = [math]::Round(($currentBytes / $totalBytes) * 100, 3)
        $percentStr = "{0:N3}" -f $numericPercent

        # Convert byte to human redable
        $currentReadable = Convert-ByteToReadableSize -Byte $currentBytes
        $totalReadable = Convert-ByteToReadableSize -Byte $totalBytes

        # Progress bar
        $progressMessage = "Copied $currentReadable of $totalReadable ($percentStr `%) - File: $($file.Name) $($file.Length) B"
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }

        Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Log withe space
    Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Completed copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Sleeping 250 milliseconds" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Start-Sleep -Milliseconds 250

    if ($null -eq $ParentId) {
        Write-Progress -Id $Id -Activity "Copy in progress..." -Completed
    }
    else {
        Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Completed
    }

    Write-LogDebug -Message "[$FunctionName] Function terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region FileByte
function Copy-ProgressFileByte {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [switch]$print,
        [switch]$PrintTime,

        # Extra parameter self defined
        [pscustomobject]$LogSetting = $ProgressFileLogSetting,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO"
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "New-LogSetting"             = "PSWriteLog"
        "Write-LogTrace"             = "PSWriteLog"
        "Write-LogDebug"             = "PSWriteLog"
        "Write-LogWarn"              = "PSWriteLog"
        "Write-LogException"         = "PSWriteLog"
        "Convert-ByteToReadableSize" = "PSConvert"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    if ($null -eq $LogSetting) {
        $logFilename = "${$FunctionName}Log_$LogMinLevel"
        $logFolder = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )
        $LogSetting = New-LogSetting -Filename $logFilename -Path $logFolder -LogMinLevel $LogMinLevel -DateInLogFile
    }

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start log
    Write-LogDebug -Message "[$FunctionName] Initialization function" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Parmater log
    Write-LogTrace -Message "[$FunctionName] Source: $Source - Destination: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Id: $Id - ParentId: $(if($null -eq $ParentId) {"null"} else {$ParentId})" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Create main destination folder
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-LogDebug -Message "[$FunctionName] Created main destination directory: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Get the list of all files recursively
    $files = Get-ChildItem -Path $Source -Recurse -File
    $PreviewFileNumber = 50
    $preview = $files | Select-Object -First $PreviewFileNumber
    Write-LogTrace -Message "[$FunctionName] Preview of first $PreviewFileNumber files:`n$($preview | Format-Table -AutoSize | Out-String)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTim

    $currentFile = 0
    $totalFiles = $files.Count
    Write-LogTrace -Message "[$FunctionName] Total files: $totalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $currentBytes = 0
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    Write-LogTrace -Message "[$FunctionName] Total bytes: $totalBytes" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Log before foreach
    Write-LogDebug -Message "[$FunctionName] Starting file copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    foreach ($file in $files) {
        # log White space
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Resolve source and destination path
        $relativePath = $file.FullName.Substring((Resolve-Path $Source).Path.Length)
        $destPath = Join-Path -Path $Destination -ChildPath $relativePath
        Write-LogTrace -Message "[$FunctionName] Relative Source: .$relativePath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogTrace -Message "[$FunctionName] Destination: $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Extract destination dir
        $destDir = Split-Path -Path $destPath -Parent
        Write-LogTrace -Message "[$FunctionName] Extracted destination dir: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Create sub destination folder
        if (-not (Test-Path -Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Write-LogDebug -Message "[$FunctionName] Created sub destination directory: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }

        # Copy item
        try {
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        catch {
            $ErrorRecord = $_
            Write-LogWarn -Message "[$FunctionName] Failed to copy file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            Write-LogException -ErrorRecord $ErrorRecord -Prefix "Copy-Item" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        finally {
            $currentFile++
            $currentBytes += $file.Length
        }

        # Update parameter for progress bar
        $numericPercent = [math]::Round(($currentBytes / $totalBytes) * 100, 3)
        $percentStr = "{0:N3}" -f $numericPercent

        # Convert byte to human redable
        $currentReadable = Convert-ByteToReadableSize -Byte $currentBytes
        $totalReadable = Convert-ByteToReadableSize -Byte $totalBytes

        # Progress bar
        $progressMessage = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentStr `%) - File: $($file.Name) $($file.Length) B"
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }

        Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Log withe space
    Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Completed file copy loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Sleeping 250 milliseconds" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Start-Sleep -Milliseconds 250

    if ($null -eq $ParentId) {
        Write-Progress -Id $Id -Activity "Copy in progress..." -Completed
    }
    else {
        Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Completed
    }

    Write-LogDebug -Message "[$FunctionName] Function terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Buffer
function Copy-ProgressBuffer {
    [CmdletBinding()]
    param(
        # Copy path
        [string]$SourceFile,
        [string]$DestinationFile,

        # Progress bar information
        [int]$CurrentFile,
        [int]$TotalFiles,
        [ref]$GlobalCurrentBytes,
        [long]$TotalBytes,

        # Buffer
        [long]$BufferSize,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [switch]$print,
        [switch]$PrintTime,

        # Extra parameter self defined
        [pscustomobject]$LogSetting = $ProgressFileLogSetting,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO"
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "New-LogSetting"             = "PSWriteLog"
        "Write-LogTrace"             = "PSWriteLog"
        "Write-LogDebug"             = "PSWriteLog"
        "Write-LogWarn"              = "PSWriteLog"
        "Write-LogException"         = "PSWriteLog"
        "Convert-ByteToReadableSize" = "PSConvert"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    if ($null -eq $LogSetting) {
        $logFilename = "${$FunctionName}Log_$LogMinLevel"
        $logFolder = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )
        $LogSetting = New-LogSetting -Filename $logFilename -Path $logFolder -LogMinLevel $LogMinLevel -DateInLogFile
    }

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start log
    Write-LogDebug -Message "[$FunctionName] Initialization function" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Parmater log
    Write-LogTrace -Message "[$FunctionName] Source: $SourceFile - Destination: $DestinationFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] File $CurrentFile of $TotalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Byte: $($GlobalCurrentBytes.Value) of $TotalBytes" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Buffer: $($BufferSize / 1MB) MB" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Id: $Id - ParentId: $(if($null -eq $ParentId) {"null"} else {$ParentId})" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Create object buffer
    $buffer = New-Object byte[] $BufferSize
    Write-LogDebug -Message "[$FunctionName] Created byte buffer: $($BufferSize / 1MB) MB" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Open read stream
    $SourceStream = [System.IO.File]::OpenRead($SourceFile)
    Write-LogDebug -Message "[$FunctionName] Opened read stream on source: $SourceFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Creat write stream
    $destStream = [System.IO.File]::Create($DestinationFile)
    Write-LogDebug -Message "[$FunctionName] Created write stream to destination: $DestinationFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    try {
        # Log before while
        Write-LogDebug -Message "[$FunctionName] Enter while loop to copy buffer" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        while (($bytesRead = $SourceStream.Read($buffer, 0, $BufferSize)) -gt 0) {
            # Write the current buffer chunk to the destination stream
            $destStream.Write($buffer, 0, $bytesRead)

            # Update the global counter for the total bytes copied so far
            $globalCurrentBytes.Value += $bytesRead

            # Update parameter for progress bar
            $numericPercent = [math]::Round(($globalCurrentBytes.Value / $TotalBytes) * 100, 3)
            $percentStr = "{0:N3}" -f $numericPercent

            # Convert byte to human redable
            $currentReadable = Convert-ByteToReadableSize -Byte $globalCurrentBytes.Value
            $totalReadable = Convert-ByteToReadableSize -Byte $totalBytes

            # Progress bar
            $progressMessage = "File $CurrentFile of $TotalFiles - Copied $currentReadable of $totalReadable ($percentStr `%) - File: $([System.IO.Path]::GetFileName($SourceFile)) - $bytesRead B transferred"
            if ($null -eq $ParentId) {
                Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
            }
            else {
                Write-Progress -Id $Id -ParentId $ParentId -Status $progressMessage -PercentComplete $numericPercent
            }

            Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }

        Write-LogTrace -Message "[$FunctionName] End of stream reached" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogDebug -Message "[$FunctionName] Exit while loop" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    catch {
        $ErrorRecord = $_
        Write-LogWarn -Message "[$FunctionName] Failed to copy: $SourceFile to $DestinationFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogException -ErrorRecord $ErrorRecord -Prefix "Stream" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    finally {
        $SourceStream.Close()
        Write-LogDebug -Message "[$FunctionName] Closed read stream: $SourceFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        $destStream.Close()
        Write-LogDebug -Message "[$FunctionName] Closed write stream: $DestinationFile" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    Write-LogDebug -Message "[$FunctionName] Terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion


# ================================================================================================================================ #

#region Stream
function Copy-ProgressStream {
    [CmdletBinding()]
    param (
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # If the file is greater than this value, block copy will be used
        [long]$ChunkThresholdMB = 8,

        # Buffer for block copying
        [long]$BufferSizeMB = 4,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [switch]$print,
        [switch]$PrintTime,

        # Extra parameter self defined
        [pscustomobject]$LogSetting = $ProgressFileLogSetting,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO"
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "New-LogSetting"             = "PSWriteLog"
        "Write-LogTrace"             = "PSWriteLog"
        "Write-LogDebug"             = "PSWriteLog"
        "Write-LogWarn"              = "PSWriteLog"
        "Write-LogException"         = "PSWriteLog"
        "Convert-ByteToReadableSize" = "PSConvert"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    if ($null -eq $LogSetting) {
        $logFilename = "${$FunctionName}Log_$LogMinLevel"
        $logFolder = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )
        $LogSetting = New-LogSetting -Filename $logFilename -Path $logFolder -LogMinLevel $LogMinLevel -DateInLogFile
    }

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start log
    Write-LogDebug -Message "[$FunctionName] Initialization function" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $ChunkThreshold = $ChunkThresholdMB * 1MB
    $BufferSize = $BufferSizeMB * 1MB

    # Parmater log
    Write-LogTrace -Message "[$FunctionName] Source: $Source - Destination: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] ChunkThresholdMB: $ChunkThresholdMB MB - BufferSizeMB: $BufferSizeMB MB" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Id: $Id - ParentId: $(if($null -eq $ParentId) {"null"} else {$ParentId})" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Create main destination folder
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-LogDebug -Message "[$FunctionName] Created main destination dir: $Destination" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Get the list of all files recursively
    $files = Get-ChildItem -Path $Source -Recurse -File
    $PreviewFileNumber = 50
    $preview = $files | Select-Object -First $PreviewFileNumber
    Write-LogTrace -Message "[$FunctionName] Preview of first 50 files:`n$($preview | Format-Table -AutoSize | Out-String)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $currentFile = 0
    $totalFiles = $files.Count
    Write-LogTrace -Message "[$FunctionName] Total files: $totalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $currentBytes = 0
    $globalCurrentBytes = [ref]$currentBytes
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    Write-LogTrace -Message "[$FunctionName] Total bytes: $totalBytes" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Log before foreach
    Write-LogDebug -Message "[$FunctionName] Enter foreach copy file in files" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    foreach ($file in $files) {
        # log White space
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Resolve source and destination path
        $relativePath = $file.FullName.Substring((Resolve-Path $Source).Path.Length)
        $destPath = Join-Path -Path $Destination -ChildPath $relativePath
        Write-LogTrace -Message "[$FunctionName] Relative Source: .$relativePath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        Write-LogTrace -Message "[$FunctionName] Destination: $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Extract destination dir
        $destDir = Split-Path -Path $destPath -Parent
        Write-LogTrace -Message "[$FunctionName] Extract destination dir: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        # Create sub destination folder
        if (-not (Test-Path -Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Write-LogDebug -Message "[$FunctionName] Created destination dir: $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }

        # Copy item
        if ($file.Length -ge $ChunkThreshold) {

            # Use Copy-ProgressBuffer for file bigger than ChunkThreshold
            try {
                Copy-ProgressBuffer -SourceFile $file.FullName -DestinationFile $destPath -CurrentFile $currentFile -TotalFiles $totalFiles `
                    -GlobalCurrentBytes $globalCurrentBytes -TotalBytes $totalBytes -BufferSize $BufferSize -Id $Id -ParentId $ParentId `
                    -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
                Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            }
            catch {
                $ErrorRecord = $_
                Write-LogWarn -Message "[$FunctionName] Failed to copy file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
                Write-LogException -ErrorRecord $ErrorRecord -Prefix $FunctionName -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            }
            finally {
                $currentFile++
            }
        }
        else {

            # Use Copy-Item for file Smaller than ChunkThreshold
            try {
                Copy-Item -Path $file.FullName -Destination $destPath -Force
                Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            }
            catch {
                $ErrorRecord = $_
                Write-LogWarn -Message "[$FunctionName] Failed to copy file: $file to $destDir" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
                Write-LogException -ErrorRecord $ErrorRecord -Prefix $FunctionName -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            }
            finally {
                $currentFile++
                $globalCurrentBytes.Value += $file.Length
            }

            # Update parameter for progress bar
            $numericPercent = [math]::Round(($globalCurrentBytes.Value / $totalBytes) * 100, 3)
            $percentStr = "{0:N3}" -f $numericPercent

            # Convert byte to human redable
            $currentReadable = Convert-ByteToReadableSize -byte $globalCurrentBytes.Value
            $totalReadable = Convert-ByteToReadableSize -byte $totalBytes

            $progressMessage = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentStr `%) - File: $($file.Name)"
            if ($null -eq $ParentId) {
                Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
            }
            else {
                Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
            }

            Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
    }

    # Log withe space
    Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Exit foreach copy file in files" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Sleeping 250 Milliseconds" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Start-Sleep -Milliseconds 250

    # Close progress bar
    if ($null -eq $ParentId) {
        Write-Progress -Id $Id -Activity "Copy in progress..." -Completed
    }
    else {
        Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Completed
    }

    Write-LogTrace -Message "[$FunctionName] All files copied successfully (100%)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogDebug -Message "[$FunctionName] Terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion


# ================================================================================================================================ #

#region To VM
<# function Copy-ProgressToVM {
    [CmdletBinding()]
    param (
        # Copy path
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        # Virtual machine name
        [Parameter(Mandatory = $true)]
        [string]$VmName,

        # Progress bar
        [int]$Id = 0,
        [System.Nullable[int]]$ParentId = $null,

        # Log
        [pscustomobject]$LogSetting = $ProgressToVMLogSetting,
        [switch]$print,
        [switch]$PrintTime
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "Write-LogTrace"             = "PSWriteLog"
        "Write-LogDebug"             = "PSWriteLog"
        "Write-LogWarn"              = "PSWriteLog"
        "Write-LogException"         = "PSWriteLog"
        "Convert-ByteToReadableSize" = "PSConvert"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    Write-LogDebug -Message "[$FunctionName] Initialization" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Parameters: Source='$Source', Destination='$Destination', VmName='$VmName', Id=$Id, ParentId=$ParentId" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # File listing
    $files = Get-ChildItem -Path $Source -Recurse -File
    $preview = $files | Select-Object -First 50
    Write-LogTrace -Message "[$FunctionName] File preview:`n$($preview | Format-Table -AutoSize | Out-String)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $currentFile = 0
    $totalFiles = $files.Count
    Write-LogTrace -Message "[$FunctionName] Total files: $totalFiles" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    $currentBytes = 0
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    Write-LogTrace -Message "[$FunctionName] Total bytes: $totalBytes" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Enter foreach copy file in files" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring((Resolve-Path $Source).Path.Length)
        $destPath = Join-Path -Path $Destination -ChildPath $relativePath

        Write-LogTrace -Message "[$FunctionName] RelativePath='.$relativePath', DestinationPath='$destPath'" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        try {
            # Copy file to VM
            Copy-VMFile -Name $VmName -SourcePath $file.FullName -DestinationPath $destPath -FileSource Host -CreateFullPath -Force
            Write-LogTrace -Message "[$FunctionName] Copied file: $file to $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        catch {
            $ErrorRecord = $_
            Write-LogWarn -Message "[$FunctionName] Failed to copy file: $file to $destPath" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
            Write-LogException -ErrorRecord $ErrorRecord -Prefix $FunctionName -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        }
        finally {
            $currentFile++
            $currentBytes += $file.Length
        }

        # Progress percentage
        $numericPercent = [math]::Round(($currentBytes / $totalBytes) * 100, 3)
        $percentStr = "{0:N3}" -f $numericPercent

        # Readable format
        $currentReadable = Convert-ByteToReadableSize -byte $currentBytes
        $totalReadable = Convert-ByteToReadableSize -byte $totalBytes

        $progressMessage = "File $currentFile of $totalFiles - Copied $currentReadable of $totalReadable ($percentStr `%) - File: $($file.Name) $($file.Length) B"
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Status $progressMessage -PercentComplete $numericPercent
        }

        Write-LogTrace -Message "[$FunctionName] $progressMessage" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Log withe space
        Write-LogTrace -Message "[$FunctionName]" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    Write-LogDebug -Message "[$FunctionName] Exit foreach copy file in files" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogTrace -Message "[$FunctionName] Sleeping 250 ms" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Start-Sleep -Milliseconds 250

    # Close progress bar
    if ($null -eq $ParentId) {
        Write-Progress -Id $Id -Activity "Copy in progress..." -Completed
    }
    else {
        Write-Progress -Id $Id -ParentId $ParentId -Activity "Copy in progress..." -Completed
    }

    Write-LogTrace -Message "[$FunctionName] All files copied successfully (100%)" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    Write-LogDebug -Message "[$FunctionName] Terminated" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
} #>
#endregion


# ================================================================================================================================ #

# Set Alias
Set-Alias -Name "ProgressFile" -Value Copy-ProgressFile
Set-Alias -Name "ProgressByte" -Value Copy-ProgressByte
Set-Alias -Name "ProgressFileByte" -Value Copy-ProgressFileByte
Set-Alias -Name "ProgressBuffer" -Value Copy-ProgressBuffer
Set-Alias -Name "ProgressStream" -Value Copy-ProgressStream
Set-Alias -Name "ProgressToVM" -Value Copy-ProgressToVM

# ================================================================================================================================ #

# Export functions and aliases
Export-ModuleMember -Function @(
    "Copy-ProgressFile",
    "Copy-ProgressByte",
    "Copy-ProgressFileByte",
    "Copy-ProgressBuffer",
    "Copy-ProgressStream",
    "Copy-ProgressToVM"
) -Alias @(
    "ProgressFile",
    "ProgressByte",
    "ProgressFileByte",
    "ProgressBuffer",
    "ProgressStream",
    "ProgressToVM"
)

$Script:ByteToReadableSize = New-LogSetting -File "Convert-ByteToReadableSize" -Path C:\Temp\Log -LogMinLevel TRACE
$Script:LogSetting = New-LogSetting -Filename "Copy-ProgressFile" -Path C:\Temp\Log -LogMinLevel TRACE
Copy-ProgressFile -Source ..\..\..\..\..\Temp\Fase -Destination C:\Temp\Fase2 -LogSetting $Script:LogSetting

$Script:LogSetting = New-LogSetting -Filename "Copy-ProgressByte" -Path C:\Temp\Log -LogMinLevel TRACE
Copy-ProgressByte -Source C:\Temp\Fase -Destination C:\Temp\Fase3 -LogSetting $Script:LogSetting

$Script:LogSetting = New-LogSetting -Filename "Copy-ProgressFileByte" -Path C:\Temp\Log -LogMinLevel TRACE
Copy-ProgressFileByte -Source C:\Temp\Fase -Destination C:\Temp\Fase4 -LogSetting $LogSetting

$Script:LogSetting = New-LogSetting -Filename "Copy-ProgressStream" -Path C:\Temp\Log -LogMinLevel TRACE
Copy-ProgressStream -Source C:\Temp\Fase -Destination C:\Temp\Fase5 -LogSetting $Script:LogSetting