#File: NoveLib/Public/System/Get-ComputerUptime.ps1

function Get-ComputerUptime {
    param (
        [ValidateSet("LastBootUpTime", "TimeStamp", "UnixStyle")]
        $Mode = "LastBootUpTime"
    )

    switch ($Mode) {
        "LastBootUpTime" { (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime }
        "TimeStamp" {
            $now = Get-Date
            $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $uptime = $now - $boot

            # Format uptime
            $days = [math]::Floor($uptime.TotalDays)
            $hours = $uptime.Hours
            $minutes = $uptime.Minutes
            $seconds = $uptime.Seconds

            # Correct grammar output
            $dayStr = if ($days -eq 1) { "day" } else { "days" }
            $hourStr = if ($hours -eq 1) { "hour" } else { "hours" }
            $minuteStr = if ($minutes -eq 1) { "minute" } else { "minutes" }
            $secondStr = if ($seconds -eq 1) { "second" } else { "seconds" }

            # Output
            $now = Get-Date -Format "HH:mm:ss"
            "{0} now, {1} $dayStr, {2} $hourStr, {3} $minuteStr, {4} $secondStr" -f `
                $now, $days, $hours, $minutes, $seconds
        }
        "UnixStyle" {
            $now = Get-Date
            $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $uptime = $now - $boot

            # Format uptime
            $days = [math]::Floor($uptime.TotalDays)
            $hours = $uptime.Hours
            $minutes = $uptime.Minutes

            # Count user
            $userCount = (query user 2>$null | Where-Object { $_ -match "^\s*\w" }).Count
            if (-not $userCount) { $userCount = 1 } # fallback

            # Correct grammar output
            $usersStr = if ($userCount -eq 1) { "user" } else { "users" }
            $dayStr = if ($days -eq 1) { "day" } else { "days" }

            # Output
            $now = Get-Date -Format "HH:mm:ss"
            "{0} up {1} $dayStr, {2}:{3:00}, {4} $usersStr" -f `
                $now, $days, $hours, $minutes, $userCount
        }
    }
}