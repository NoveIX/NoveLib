# =========================[ MyModule.psm1 ]========================= #

$moduleRoot = Split-Path -Parent $PSCommandPath

# Seleziona il target .NET in base all'ambiente
if ($PSEdition -eq 'Core') {
    $assemblyPath = Join-Path $moduleRoot 'bin/net8.0/MyModule.dll'
} else {
    $assemblyPath = Join-Path $moduleRoot 'bin/net48/MyModule.dll'
}

# Carica la DLL se esiste
if (Test-Path $assemblyPath) {
    Write-Verbose "Loading MyModule assembly from $assemblyPath"
    Import-Module $assemblyPath -PassThru | Out-Null
} else {
    throw "Assembly non trovato: $assemblyPath"
}

# (Facoltativo) Importa script helper, funzioni o inizializzazioni
# . "$moduleRoot\Private\Init.ps1"

# =================================================================== #
