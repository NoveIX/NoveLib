$BuildScript = $PSScriptRoot

function Build-Project {
    param(
        [switch]$Test,
        [switch]$Release
    )

    $project = Split-Path -Path $BuildScript -Parent

    # Build Project
    if ($Test) { dotnet.exe build $project -c Debug }
    if ($Release) { dotnet.exe build $project -c Release }
}