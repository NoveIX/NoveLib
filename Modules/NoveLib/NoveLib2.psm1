function Write-Test{
param (
    [Parameter(Mandatory = $true)]
    [string] $ciao
)
Write-Host $ciao }

function Write-Test
(
    [Parameter(Mandatory = $true)]
    [string] $ciao
)
{
Write-Host $ciao }


Get-Command Write-Test | Select-Object -Expand Parameters
