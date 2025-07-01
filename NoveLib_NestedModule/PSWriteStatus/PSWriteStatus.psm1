#region Status Setting
function New-StatusSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$Id,

        [System.Nullable[int]]$ParentId = $null,

        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [Parameter(Mandatory = $true)]
        [int]$TotalItems
    )

    # Returns an object with the properties needed for state tracking
    [PSCustomObject]@{
        Id         = $Id
        ParentId   = $ParentId
        Activity   = $Activity
        TotalItems = $TotalItems
    }
}
#endregion

# ================================================================================================================================ #

#region Status
function Write-Status {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$CurrentItem,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [pscustomobject]$StatusConfig
    )

    # If the parameter is not passed, use the global variable defined at the script level.
    if (-not $StatusConfig) { 
        $StatusConfig = $script:StatusConfig

        if ($null -eq $StatusConfig) { 
            throw "StatusConfig is not defined as a script variable" 
        }
    }

    # Extract values from the configuration object.
    $id = $StatusConfig.Id
    $parentId = $StatusConfig.ParentId
    $activity = $StatusConfig.Activity
    $totalItems = $StatusConfig.TotalItems

    # Calculates percentage of completion, rounded to 3 decimal places.
    $percentComplete = [math]::Round(($CurrentItem / $totalItems) * 100, 3)
    $percentStr = "{0:N3}" -f $percentComplete

    # Write progress, with or without parent ID.
    if ($null -eq $parentId) {
        Write-Progress -Id $id -Activity $activity -Status "$Status ($percentStr `%)" -PercentComplete $percentComplete
    }
    else {
        Write-Progress -Id $id -ParentId $parentId -Activity $activity -Status "$Status ($PercentStr `%)" -PercentComplete $percentComplete
    }

    # Se completato al 100%, chiudi la barra
    if ($percentComplete -ge 100) {
        if ($null -eq $ParentId) {
            Write-Progress -Id $id -Activity $activity -Completed
        }
        else {
            Write-Progress -Id $id -ParentId $parentId -Activity $activity -Completed
        }
    }
}
#endregion

# ================================================================================================================================ #

Set-Alias -Name "Status" -Value Write-Status

# ================================================================================================================================ #

Export-ModuleMember -Function @(
    "Write-Status"
) -Alias @(
    "Status"
)