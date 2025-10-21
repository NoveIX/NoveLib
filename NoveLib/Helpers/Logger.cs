using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace NoveLib.Helpers
{
    // Log Level Enum
    public enum LogLevel
    {
        Trace, Debug, Info, Warn, Error, Fatal, Done
    }

    // Log Format Mode
    public enum LogFormat
    {
        Time, Datetime
    }

    // Date in Log Name Mode
    public enum LogDate
    {
       None, Date, Datetime
    }

    // Console Output Mode
    public enum LogConsole
    {
        None, Message, Timestamp
    }

    // Logger Helper
    public static class Logger
    {
        //Log level mapping
        private static readonly Dictionary<LogLevel, string> LogLevelMap = new()
        {
            [LogLevel.Trace] = "TRACE",
            [LogLevel.Debug] = "DEBUG",
            [LogLevel.Info] = "INFO",
            [LogLevel.Warn] = "WARN",
            [LogLevel.Error] = "ERROR",
            [LogLevel.Fatal] = "FATAL",
            [LogLevel.Done] = "DONE"
        };

        // Log level color mapping
        private static readonly Dictionary<LogLevel, ConsoleColor> LogColorMap = new()
        {
            [LogLevel.Trace] = ConsoleColor.DarkGray,
            [LogLevel.Debug] = ConsoleColor.Gray,
            [LogLevel.Info] = ConsoleColor.DarkCyan,
            [LogLevel.Warn] = ConsoleColor.DarkYellow,
            [LogLevel.Error] = ConsoleColor.Red,
            [LogLevel.Fatal] = ConsoleColor.DarkRed,
            [LogLevel.Done] = ConsoleColor.Green,
        };

        // Log format mapping
        private static readonly Dictionary<LogFormat, string> LogFormatMap = new()
        {
            [LogFormat.Time] = "HH:mm:ss",
            [LogFormat.Datetime] = "yyyy-MM-dd HH:mm:ss"
        };

        // Log console output mapping
        private static readonly Dictionary<LogConsole, (bool text, bool time)> LogConsoleMap = new()
        {
            [LogConsole.None] = (false, false),
            [LogConsole.Message] = (true, false),
            [LogConsole.Timestamp] = (true, true)
        };

        // Get timestamp
        private static string GetTimestamp(LogFormat format, bool millisecond)
        {
            string logFormat = LogFormatMap[format] + (millisecond ? ".fff" : "");
            return DateTime.Now.ToString(logFormat);
        }

        // Write log to console
        internal static void WriteLogConsole(LogLevel level, string message)
        {
            Console.Write("[");
            Console.ForegroundColor = LogColorMap[level];
            Console.Write(level.ToString().ToUpperInvariant());
            Console.ResetColor();
            Console.WriteLine($"] - {message}");
        }

        // Logger
        internal static void WriteLog(LogLevel level, string message, LogSetting setting, bool print, bool printTime)
        {
            // Check log level
            if (level < setting.LogMinLevel) return;

            // Get timestamp
            string timeStamp = GetTimestamp(setting.LogFormat, setting.Millisecond);

            // Print to console
            var (text, time) = LogConsoleMap[setting.ConsoleOutput];
            if (text || print)
            {
                // Print timestamp if needed
                if (time || printTime) Console.Write($"[{timeStamp}] ");
                WriteLogConsole(level, message);
            }

            // Create log line
            string logLine = $"[{timeStamp}] [{LogLevelMap[level]}] - {message}";

            // Ensure directory exists
            if (!File.Exists(setting.LogPath)) FileSystemHelper.NewFile(setting.LogPath);

            // Write to file
            try
            {
                using FileStream fs = new(setting.LogPath, FileMode.Append, FileAccess.Write, FileShare.Read);
                using StreamWriter sw = new(fs, Encoding.UTF8);
                sw.WriteLine(logLine);
                sw.Flush();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine($"[Logger] Error writing to file: {ex.Message}");
                Console.ResetColor();
            }
        }

        internal static LogSetting CreateLogSetting(string logName, string logPath, LogLevel logMinLevel, LogFormat logFormat, bool millisecond, LogDate dateLogName, LogConsole consoleOutput, bool userLogName, bool userLogDir)
        {
            // Log path
            if (string.IsNullOrWhiteSpace(logPath)) logPath = Path.Combine(Environment.CurrentDirectory, "logs");
            else if (!Path.IsPathRooted(logPath)) logPath = Path.GetFullPath(Path.Combine(Environment.CurrentDirectory, logPath));

            // Log name
            logName = string.IsNullOrWhiteSpace(logName) ? "log" : Path.GetFileNameWithoutExtension(logName);

            // Add Username in log name
            if (userLogName) logName += $"_{Environment.UserName}";

            // Date in log name
            if (dateLogName == LogDate.Date) logName += $"_{DateTime.Now:yyyy-MM-dd}";
            else if (dateLogName == LogDate.Datetime) logName += $"_{DateTime.Now:yyyy-MM-dd_HH-mm-ss}";

            // Add extension
            logName += ".log";

            // Add user subdir
            logPath = userLogDir
                ? Path.Combine(logPath, Environment.UserName, logName)
                : Path.Combine(logPath, logName);

            // Create LogSetting
            return new LogSetting(logPath, logMinLevel, logFormat, consoleOutput, millisecond);
        }
    }
}
