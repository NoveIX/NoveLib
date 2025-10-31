using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Management;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

/*
namespace NoveLib.Source.Commands
{
    public class SystemCommand
    {
        using System;
using System.Diagnostics;
using System.Linq;
using System.Management; // Per WMI (Win32_OperatingSystem)
using System.Text.RegularExpressions;

public static class SystemInfo
    {
        public static string GetComputerUptime(string mode = "LastBootUpTime")
        {
            mode = mode switch
            {
                "LastBootUpTime" => "LastBootUpTime",
                "TimeStamp" => "TimeStamp",
                "UnixNoUsage" => "UnixNoUsage",
                "Unix" => "Unix",
                _ => throw new ArgumentException("Invalid mode specified.", nameof(mode))
            };

            // Ottieni la data di avvio dal WMI
            var bootTime = GetLastBootUpTime();
            var now = DateTime.Now;
            var uptime = now - bootTime;

            int days = (int)Math.Floor(uptime.TotalDays);
            int hours = uptime.Hours;
            int minutes = uptime.Minutes;
            int seconds = uptime.Seconds;

            // --- Modalità selezionata ---
            switch (mode)
            {
                case "LastBootUpTime":
                    return bootTime.ToString("yyyy-MM-dd HH:mm:ss");

                case "TimeStamp":
                    string dayStr = days == 1 ? "day" : "days";
                    string hourStr = hours == 1 ? "hour" : "hours";
                    string minuteStr = minutes == 1 ? "minute" : "minutes";
                    string secondStr = seconds == 1 ? "second" : "seconds";
                    return $"{now:HH:mm:ss} now, {days} {dayStr}, {hours} {hourStr}, {minutes} {minuteStr}, {seconds} {secondStr}";

                case "UnixNoUsage":
                    int userCount = GetLoggedInUserCount();
                    if (userCount == 0) userCount = 1; // fallback

                    string dayStrU = days == 1 ? "day" : "days";
                    string userStr = userCount == 1 ? "user" : "users";
                    return $"{now:HH:mm:ss} up {days} {dayStrU}, {hours}:{minutes:00}, {userCount} {userStr}";

                case "Unix":
                    userCount = GetLoggedInUserCount();
                    if (userCount == 0) userCount = 1;

                    float cpuUsage = GetCpuUsage();
                    double ramUsage = GetMemoryUsagePercent();

                    string dayStrX = days == 1 ? "day" : "days";
                    string userStrX = userCount == 1 ? "user" : "users";
                    return $"{now:HH:mm:ss} up {days} {dayStrX}, {hours}:{minutes:00}, {userCount} {userStrX}, CPU: {cpuUsage:F1}% RAM: {ramUsage:F1}%";

                default:
                    throw new ArgumentException("Unknown mode.");
            }
        }

        // --- Helper: ottiene la data di avvio ---
        private static DateTime GetLastBootUpTime()
        {
            using var searcher = new ManagementObjectSearcher("SELECT LastBootUpTime FROM Win32_OperatingSystem");
            foreach (var obj in searcher.Get())
            {
                string raw = obj["LastBootUpTime"].ToString()!;
                return ManagementDateTimeConverter.ToDateTime(raw);
            }
            return DateTime.MinValue;
        }

        // --- Helper: ottiene l’uso CPU (% totale) ---
        private static float GetCpuUsage()
        {
            using var cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            cpuCounter.NextValue(); // prima lettura "a vuoto"
            System.Threading.Thread.Sleep(500);
            return cpuCounter.NextValue();
        }

        // --- Helper: ottiene uso RAM (% usata) ---
        private static double GetMemoryUsagePercent()
        {
            using var searcher = new ManagementObjectSearcher("SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem");
            foreach (var obj in searcher.Get())
            {
                double total = Convert.ToDouble(obj["TotalVisibleMemorySize"]);
                double free = Convert.ToDouble(obj["FreePhysicalMemory"]);
                return Math.Round(((total - free) / total) * 100, 1);
            }
            return 0;
        }

        // --- Helper: conta gli utenti loggati ---
        private static int GetLoggedInUserCount()
        {
            try
            {
                var process = new Process
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "query",
                        Arguments = "user",
                        RedirectStandardOutput = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    }
                };
                process.Start();
                string output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();

                var matches = Regex.Matches(output, @"^\s*\w", RegexOptions.Multiline);
                return matches.Count;
            }
            catch
            {
                return 1; // fallback
            }
        }
    }

}
*/