# === CONFIG ===
$source = "C:\Temp\1.20.1"
$destination = "C:\Temp\Backup"
$copyJobs = 16      # primi 16
$fixJobs  = 16      # secondi 16

# === PREPARA FILE ===
$items = Get-ChildItem $source -Recurse -File -Force
$chunkSize = [Math]::Ceiling($items.Count / $copyJobs)
$chunks = @()

for ($i = 0; $i -lt $copyJobs; $i++) {
    $start = $i * $chunkSize
    $end = [Math]::Min(($start + $chunkSize - 1), $items.Count - 1)
    if ($start -lt $items.Count) {
        $chunks += ,@($items[$start..$end])
    }
}

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# === 1ª FASE: COPIA PARALLELA ===
Write-Host "==> Avvio dei $copyJobs job di copia..." -ForegroundColor Cyan

$copyJobList = @()
for ($i = 0; $i -lt $chunks.Count; $i++) {
    $chunk = $chunks[$i]
    $copyJobList += Start-Job -Name "Copy_$i" -ArgumentList $chunk, $source, $destination, $i -ScriptBlock {
        param($chunk, $source, $destination, $index)
        foreach ($file in $chunk) {
            try {
                $relative = $file.FullName.Substring($source.Length)
                $targetPath = Join-Path $destination $relative
                $targetDir = Split-Path $targetPath -Parent
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Copy-Item $file.FullName -Destination $targetPath -Force
            }
            catch {
                Write-Warning "[$index] Errore copiando $($file.FullName): $_"
            }
        }
        "Copy job $index completato."
    }
}

Receive-Job -Wait -AutoRemoveJob $copyJobList | Out-Host
Write-Host "`n✅ Tutti i job di copia completati." -ForegroundColor Green

# === 2ª FASE: SINCRONIZZAZIONE ATTRIBUTI ===
Write-Host "==> Avvio dei $fixJobs job di sistemazione filesystem..." -ForegroundColor Cyan

# Suddividi anche la destinazione in 16 parti
$destItems = Get-ChildItem $destination -Recurse -File -Force
$chunkSizeFix = [Math]::Ceiling($destItems.Count / $fixJobs)
$fixChunks = @()

for ($i = 0; $i -lt $fixJobs; $i++) {
    $start = $i * $chunkSizeFix
    $end = [Math]::Min(($start + $chunkSizeFix - 1), $destItems.Count - 1)
    if ($start -lt $destItems.Count) {
        $fixChunks += ,@($destItems[$start..$end])
    }
}

$fixJobList = @()
for ($i = 0; $i -lt $fixChunks.Count; $i++) {
    $chunk = $fixChunks[$i]
    $fixJobList += Start-Job -Name "Fix_$i" -ArgumentList $chunk, $source, $destination, $i -ScriptBlock {
        param($chunk, $source, $destination, $index)

        $totalItem = $chunk.Count
        $currentItem = 0

        foreach ($destFile in $chunk) {
            try {
                # Calcola percorso relativo
                $relative = $destFile.FullName.Substring($destination.Length)
                $sourcePath = Join-Path $source $relative

                if (Test-Path $sourcePath) {
                    [System.IO.FileSystemInfo]$sourceItem = Get-Item -LiteralPath $sourcePath
                    [System.IO.FileSystemInfo]$destinationItem = Get-Item -LiteralPath $destFile.FullName

                    if ($sourceItem -and $destinationItem) {
                        try {
                            $destinationItem.Attributes = $sourceItem.Attributes
                        }
                        catch {
                            Write-Warning -Message "($currentItem / $totalItem) Failed to set attributes on: $($destFile.FullName) - $($_.Exception.Message)"
                        }
                    }
                }
            }
            catch {
                Write-Warning "[$index] Errore sistemando $($destFile.FullName): $_"
            }
            $currentItem++
        }

        "Fix job $index completato."
    }
}

Receive-Job -Wait -AutoRemoveJob $fixJobList | Out-Host
Write-Host "`n✅ Tutti i job di sistemazione completati." -ForegroundColor Green
