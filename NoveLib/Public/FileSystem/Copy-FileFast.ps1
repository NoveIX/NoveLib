# File: NoveLib\Public\FileSystem\Copy-FileFast.ps1

function Copy-FileFast {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination
    )

    # Create the destination if it does not exist
    if (-not (Test-Path -Path $Destination -PathType Container)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    # Resolve full path
    $Source = Resolve-Path -LiteralPath $Source
    $Destination = Resolve-Path -LiteralPath $Destination

    # Recursive copy with attribute preservation
    [array]$items = Get-ChildItem -Path $Source -Recurse -Force

    #Counter
    [int]$currentItem = 0
    [int]$totalItem = $items.Count
    [int]$decimalPlaces = 2

    foreach ($item in $items) {
        # Progress bar
        $currentItem++
        [double]$averagePercent = (($currentItem / $totalItem) * 100)
        [double]$percentComplete = [math]::Round($averagePercent, $decimalPlaces)
        [string]$percentString = $percentComplete.ToString("N$decimalPlaces")
        [string]$status = "Item $currentItem of $totalItem ($percentString `%) - $($item.Name)"
        Write-Progress -Id 0 -Activity "Copy in progress..." -Status $status -PercentComplete $percentComplete

        # Calculate path relative path on destination path
        [string]$SourceRelativePath = $item.FullName.Substring((Resolve-Path $Source).Path.Length)
        [string]$DestinationFullPath = Join-Path -Path $Destination -ChildPath $SourceRelativePath

        # Copy item to destination
        if ($item.PSIsContainer) {
            # Copy folder
            #[string]$DestinationFullPathParent = Split-Path $DestinationFullPath -Parent
            #Copy-Item -Path $item.FullName -Destination $DestinationFullPathParent -Force
            if (-not (Test-Path -Path $DestinationFullPath)) {
                New-Item -Path $DestinationFullPath -ItemType Directory -Force | Out-Null
            }
        }
        else {
            # Copy item
            #Copy-Item -Path $item.FullName -Destination $DestinationFullPath -Force
            [System.IO.File]::Copy($item.FullName, $DestinationFullPath, $true)
        }

        # restore attribute
        [System.IO.FileSystemInfo]$sourceItem = Get-Item -LiteralPath $item.FullName -Force
        [System.IO.FileSystemInfo]$destinationItem = Get-Item -LiteralPath $DestinationFullPath -Force
        if ($sourceItem -and $destinationItem) {
            try {
                $destinationItem.Attributes = $sourceItem.Attributes
            }
            catch {
                Write-LogHost -Message "($currentItem / $totalItem) Failed to set attributes on: $DestinationFullPath - $_" -Level FAIL
            }
        }
    }

    Start-Sleep -Milliseconds 200
    Write-Progress -Id 0 -Activity "Copy completed" -Completed
    return 0
}