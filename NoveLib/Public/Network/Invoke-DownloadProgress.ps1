function Invoke-DownloadProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$URL,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [string]$OutFile,

        [int]$DecimalPlaces = 2
    )

    # Ensure destination folder exists
    Test-Directory -Ensure -Path $Destination | Out-Null

    # If OutFile is not provided, extract from URL
    if (-not $OutFile) {
        try {
            $uri = [System.Uri]::new($URL)
            $OutFile = [System.IO.Path]::GetFileName($uri.AbsolutePath)
            if (-not $OutFile) { $OutFile = "downloaded_file" }
        }
        catch {
            $OutFile = "downloaded_file"
        }
    }

    # Sanitize file name
    $OutFile = ($OutFile -replace '[<>:"/\\|?*]', '_')

    $SavePath = Join-Path -Path $Destination -ChildPath $OutFile

    try {
        # Try BITS
        throw
        Start-BitsTransfer -Source $URL -Destination $SavePath -ErrorAction Stop
        return
    }
    catch {
        # Manual fallback
        $writer = $null
        $responseStream = $null

        try {
            $response = Invoke-WebRequest -Uri $URL -Method Head -UseBasicParsing
            $totalBytes = [int64]$response.Headers["Content-Length"]

            $bufferSize = 16 * 1MB
            $buffer = New-Object byte[] $bufferSize
            $request = [System.Net.HttpWebRequest]::Create($URL)
            $writer = [System.IO.File]::OpenWrite($SavePath)

            $response = $request.GetResponse()
            $responseStream = $response.GetResponseStream()

            $totalRead = 0

            $activity = "Downloading..."
            while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $writer.Write($buffer, 0, $read)
                $totalRead += $read

                # Calculate percent
                [double]$averagePercent = (($totalRead / $totalBytes) * 100)

                # Compute and format progress
                [double]$percentComplete = [math]::Round($averagePercent, $DecimalPlaces)
                [string]$percentString = "{0:N$Script:DecimalPlaces_NoveLibFX}" -f $percentComplete

                # Convert Bytes in human redable size
                $currentReadable = Convert-ByteToSizeString -Byte $totalRead -DecimalPlaces $DecimalPlaces
                $totalReadable = Convert-ByteToSizeString -Byte $totalBytes -DecimalPlaces $DecimalPlaces

                # Show Progress bar
                $status = "$currentReadable of $totalReadable ($percentString`%) - File: $OutFile"
                Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete
            }
        }
        catch {
            Write-Error "Failed to download $URL. $_"
        }
        finally {
            $writer.Close()
            $responseStream.Close()
        }
        Start-Sleep -Milliseconds 250
        Write-Progress -Activity "Download completed" -Completed
    }
}
