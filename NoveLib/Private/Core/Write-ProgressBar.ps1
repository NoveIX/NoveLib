# File: NoveLib\Private\Core\Write-ProgressBar.ps1

function Write-ProgressBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$Id,

        [System.Nullable[int]]$ParentId = $null,

        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [string]$Status = "In progress...",

        [ValidateRange(0, [long]::MaxValue)]
        [long]$PercentComplete,

        [switch]$Completed
    )

    $params = @{
        Id       = $Id
        Activity = $Activity
    }

    if ($ParentId -ne $null) { $params['ParentId'] = $ParentId }
    if ($Completed) { $params['Completed'] = $true }
    else {
        $params['Status'] = $Status
        $params['PercentComplete'] = $PercentComplete
    }

    Write-Progress @params
}

