# NoveLib.psm1

# Root del modulo
$ModuleRoot = $PSScriptRoot

# --- CARICA CLASSI (devono essere caricate prima) ---
$ClassFiles = Get-ChildItem -Path "$ModuleRoot\Private\Class" -Filter *.ps1 -Recurse -File
foreach ($file in $ClassFiles) {
    . $file.FullName
}

# --- CARICA FUNZIONI PRIVATE (NON esportate) ---
$PrivateDirs = @(
    "$ModuleRoot\Private\Core",
    "$ModuleRoot\Private\Function"
)

foreach ($dir in $PrivateDirs) {
    $PrivateFiles = Get-ChildItem -Path $dir -Recurse -Filter *.ps1 -File
    foreach ($file in $PrivateFiles) {
        . $file.FullName
    }
}

# --- CARICA FUNZIONI PUBBLICHE (Esportate) ---
$PublicDir = "$ModuleRoot\Public"
$PublicFiles = Get-ChildItem -Path $PublicDir -Recurse -Filter *.ps1 -File

foreach ($file in $PublicFiles) {
    . $file.FullName
}

# --- CARICA GLI ALIAS SE PRESENTI ---
$AliasFile = "$PublicDir\Alias\Alias.ps1"
if (Test-Path $AliasFile) {
    . $AliasFile
}

# --- ESPORTA SOLO LE FUNZIONI PUBBLICHE ---
# Trova tutte le funzioni dichiarate nei file pubblici
$ExportedFunctions = foreach ($file in $PublicFiles) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
    foreach ($func in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        $func.Name
    }
}

Export-ModuleMember -Function $ExportedFunctions



<# function Test-ModuleFunctionFileMatch {
    param (
        [Parameter(Mandatory)]
        [string]$ModuleRoot
    )

    if (-not (Test-Path $ModuleRoot)) {
        throw "Percorso non trovato: $ModuleRoot"
    }

    $results = @()

    # Trova tutti i file .ps1 ricorsivamente
    Get-ChildItem -Path $ModuleRoot -Filter *.ps1 -Recurse | ForEach-Object {
        $filePath = $_.FullName
        $fileName = $_.BaseName
        $content = Get-Content $filePath -Raw

        # Cerca la prima dichiarazione di funzione
        if ($content -match 'function\s+([^\s{(]+)') {
            $functionName = $matches[1]
            $isMatch = ($fileName -eq $functionName)
        } else {
            $functionName = $null
            $isMatch = $false
        }

        $results += [PSCustomObject]@{
            FilePath      = $filePath
            FileName      = $fileName
            FunctionName  = $functionName
            Matches       = $isMatch
        }
    }

    return $results
}
Test-ModuleFunctionFileMatch -ModuleRoot "C:\Users\stefy\Source\Repos\NoveLib\NoveLib\" #>