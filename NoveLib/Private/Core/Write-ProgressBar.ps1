# File: NoveLib\Private\Core\Write-ProgressBar.ps1

function Write-ProgressBar {
    param (
        # Unique progress bar ID
        [Parameter(Mandatory = $true)]
        [int]$Id,

        # Optional parent ID for hierarchical progress
        [System.Nullable[int]]$ParentId = $null,

        # Main activity name (displayed in progress bar)
        [Parameter(Mandatory = $true)]
        [string]$Activity,

        # Optional status message (displayed below the activity)
        [string]$Status = "In progress...",

        # Percentage of task completed (0-100)
        [ValidateRange(0, [long]::MaxValue)]
        [long]$PercentComplete,

        # If set, marks the progress as completed
        [switch]$Completed
    )

    if (-not $Completed) {
        # Show progress bar with percent complete
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity $Activity -Status $Status -PercentComplete $PercentComplete
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity $Activity -Status $Status -PercentComplete $PercentComplete
        }
    }
    else {
        # Mark progress as completed
        if ($null -eq $ParentId) {
            Write-Progress -Id $Id -Activity $Activity -Completed
        }
        else {
            Write-Progress -Id $Id -ParentId $ParentId -Activity $Activity -Completed
        }
    }
}
