# =========================[ NoveLib.psm1 ]========================== #

$moduleRoot = Split-Path -Parent $PSCommandPath

# Seleziona il target .NET in base all'ambiente

if ($PSEdition -eq 'Core') { $dllPath = Join-Path $moduleRoot 'bin/Release/net8.0/NoveLib.net8.0.dll' }
else { $dllPath = Join-Path $moduleRoot 'bin/Release/net48/NoveLib.net48.dll' }

# Carica la DLL se esiste
if (Test-Path $dllPath) { Import-Module $dllPath -PassThru }
else { throw "Assembly non trovato: $dllPath" }

# (Facoltativo) Importa script helper, funzioni o inizializzazioni
# . "$moduleRoot\Private\Init.ps1"

# =================================================================== #
