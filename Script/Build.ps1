param(
    [Parameter(ParameterSetName = "Debug")]
    [switch]$NLDebug,

    [Parameter(ParameterSetName = "Release1")]
    [switch]$NLRelease
)

$moduleName = "NoveLib"
$project = Split-Path -Path $PSScriptRoot -Parent

# Build Project
try {
    if ($NLDebug) {
        dotnet.exe build $project -c Debug
        $dir = "Debug"
    }
    elseif ($NLRelease) {
        dotnet.exe build $project -c Release
        $dir = "Release"
    }
}
catch { exit 1 }

$moduleRoot = $env:PSModulePath.Split(';') | Where-Object { $_ -like "*Documents*WindowsPowerShell*Modules*" }

if (-not $moduleRoot) { exit 1 }

$modulePath = Join-Path -Path $moduleRoot -ChildPath $moduleName
$binaryPath = Join-Path -Path $modulePath -ChildPath "Binary"

foreach ($path in @($modulePath, $binaryPath)) {
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}

try {
    $dllFiles = Get-ChildItem -Path "$project\bin\$dir" -Recurse -Filter "$moduleName*.dll" -ErrorAction Stop

    foreach ($dll in $dllFiles) { Copy-Item -Path $dll.FullName -Destination $binaryPath -Force }

    $supportFiles = @(
        "$project\$moduleName.psm1",
        "$project\$moduleName.psd1"
    )

    foreach ($file in $supportFiles) { if (Test-Path $file) { Copy-Item -Path $file -Destination $modulePath -Force } }
}
catch { exit 1 }
