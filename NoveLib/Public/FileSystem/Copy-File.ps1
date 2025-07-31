# File: NoveLib\Public\FileSystem\Copy-File.ps1

function Copy-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,

        # Overwrite files at the destination if they already exist
        [switch]$Force
    )

    # Create the destination if it does not exist
    if (-not (Test-Path -Path $Destination -PathType Container)) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
    }
    else {
        $items = Get-ChildItem -Path $Destination -Force
        if (-not ($items.Count -eq 0)) {
            if (-not ($Force)) {
                throw [System.InvalidOperationException]::new(
                    "The path '$Destination' already exists and is not empty. Operation aborted to prevent data loss. Use the 'Force' parameter to overwrite the existing contents."
                )
            }
        }
    }

    # Resolve full path
    $Source = Resolve-Path -LiteralPath $Source
    $Destination = Resolve-Path -LiteralPath $Destination

    # Recursive copy with attribute preservation
    $items = Get-ChildItem -Path $Source -Recurse -Force

    #Counter
    [int]$currentItem = 0
    [int]$totalItem = $items.Count

    foreach ($item in $items) {
        # Calculate path relative path on destination path
        [string]$SourceRelativePath = $item.FullName.Substring((Resolve-Path $Source).Path.Length)
        [string]$DestinationFullPath = Join-Path -Path $Destination -ChildPath $SourceRelativePath

        # Copy item to destination
        if ($item.PSIsContainer) {
            # Copy folder
            [string]$DestinationFullPathParent = Split-Path $DestinationFullPath -Parent
            Copy-Item -Path $item.FullName -Destination $DestinationFullPathParent -Force
        }
        else {
            # Copy item
            Copy-Item -Path $item.FullName -Destination $DestinationFullPath -Force
        }

        # restore attribute
        [System.IO.FileSystemInfo]$sourceItem = Get-Item -LiteralPath $item.FullName -Force
        [System.IO.FileSystemInfo]$destinationItem = Get-Item -LiteralPath $DestinationFullPath -Force
        if ($sourceItem -and $destinationItem) {
            try {
                $destinationItem.Attributes = $sourceItem.Attributes
            }
            catch {
                Write-Warning -Message "($currentItem / $totalItem) Failed to set attributes on: $DestinationFullPath - $_"
            }
        }

        # Write progress bar
        $currentItem++
        [double]$averagePercent = (($currentItem / $totalItem) * 100)
        [double]$percentComplete = [math]::Round($averagePercent, 3)
        [string]$percentString = "{0:N1}" -f $percentComplete

        [string]$status = "site $currentItem of $totalItem ($percentString `%) - File: $($item.Name)"
        Write-Progress -Id 0 -Activity "Copy in progress..." -Status $status -PercentComplete $percentComplete
    }
    Write-Progress -Id 0 -Activity "Copy completed" -Completed

    return 0
}
