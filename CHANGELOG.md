# 📄 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.5.1.0] - 2025-07-08

### ✨ Aggiunte

#### 📂 NoveLib

-   Aggiunta la funzione `Open-NoveLibLogFolder` apre direttamente in explorer la cartella dei log.
-   Impostato l'alias NoveLibLogFolder per la funzione `Open-NoveLibLogFolder`.

#### 📂 PSConvert

-   Aggiunta la funzione `Convert-PathToUNC` converte un percorso assoluto in un percorso di rete
-   Aggiunta i `LogTrace` e `LogDebug` alle funzioni `Convert-ByteToReadableSize` e `Convert-ByteToReadableSizeValue`

#### 📂 PSWriteLog

-   Inserito controllo inziale per tutte le funzione del modulo che avvisa in casi di errori di conflitto dei parametri inseriti
-   Inserito parametri auto configurati per la risoluzione degli errori di warning
-   Rimosso Read-Host dal catch del .NET

#### 📂 PSCopyProgress

-   Inserito controllo inziale per tutte le funzione del modulo per verifica controllo funzioni dipendenti
-   Inserito controllo inziale per tutte le funzione del modulo che avvisa in casi di errori di conflitto dei parametri inseriti

### 🛠️ Migliorie

-   Ottimizzata la funzione `Start-ModuleLoader` per una migliore compatibilità su PowerShell 5.1.

---

## [1.5.0.0] - 2025-07-08

### ✨ Aggiunte

-   Added the 5th module `PSWriteStatus` to the library.
-   Nuova funzione `New-LogStatus` per il controllo avanzato degli input.

### 🛠️ Migliorie

-   Ottimizzata la funzione `Start-ModuleLoader` per una migliore compatibilità su PowerShell 5.1.

---

## [1.4.0.0] - 2025-06-30

### ✨ Aggiunte

-   Corretto bug nella funzione `Write-LogInfo` che non scriveva correttamente su file se il path conteneva spazi.

### 📦 Migliorie minori

-   Aggiunto supporto all’opzione `-Verbose` in `Copy-WithProgress`.

---

## [1.4.0.0] - 2025-06-20

### ✨ Aggiunte

-   Nuovo modulo `My.Module.Four` per la gestione delle notifiche di sistema.
-   Funzione `Send-ToastNotification` implementata per Windows 10+.

---

## [1.2.0.0] - 2025-05-01

### ✨ Aggiunte

-   Added the 5th module `PSCopyProgress` to the library.

---

## [1.2.0.0] - 2025-05-01

### ✨ Aggiunte

-   Added the 3rd module `PSCopyProgress` to the library.

---

## [1.2.0.0] - 2025-05-01

### ✨ Aggiunte

-   Added the 2nd module `PSCopyProgress` to the library.

---

## [1.1.0.0] - 2025-05-01

### ✨ Aggiunte

-   Added the 1st module `PSWriteLog` to the library.

---

## [1.0.0.0] - 2025-05-01

### ✨ Aggiunte

-   Created the NoveLib Powershell library.

---

## 📌 Convenzione versione

`Major.Minor.Feature.Fix`

-   **Major** – Structural changes, compatibility disrupted.
-   **Minor** – Addition of internal modules.
-   **Feature** – New functions within the modules.
-   **Fix** – Bug fixes or non-invasive improvements.
