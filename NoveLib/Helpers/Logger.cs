using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace NoveLib.Helpers
{
    public enum LogLevel
    {
        Trace, Debug, Info, Warn, Error, Fatal, Done
    }

    public enum LogFormat
    {
        Time, Datetime
    }

    public enum LogDate
    {
       None, Date, Datetime
    }

    public enum LogConsole
    {
        None, Message, Timestamp
    }

    public static class Logger
    {
        // Dictionary
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

        private static readonly Dictionary<LogFormat, string> LogFormatMap = new()
        {
            [LogFormat.Time] = "HH:mm:ss",
            [LogFormat.Datetime] = "yyyy-MM-dd HH:mm:ss"
        };

        private static readonly Dictionary<LogConsole, (bool text, bool time)> LogConsoleMap = new()
        {
            [LogConsole.None] = (false, false),
            [LogConsole.Message] = (true, false),
            [LogConsole.Timestamp] = (true, true)
        };

        // Function
        private static string GetTimestamp(LogFormat format, bool millisecond)
        {
            string logFormat = LogFormatMap[format] + (millisecond ? ".fff" : "");
            return DateTime.Now.ToString(logFormat);
        }

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
            // Log guard
            if (level < setting.LogMinLevel) return;

            // Get timestamp
            string timeStamp = GetTimestamp(setting.LogFormat, setting.Millisecond);

            // Console print
            var (text, time) = LogConsoleMap[setting.ConsoleOutput];
            if (text || print)
            {
                if (time || printTime) Console.Write($"[{timeStamp}] ");
                WriteLogConsole(level, message);
            }

            // Construct log line
            string logLine = $"[{timeStamp}] [{LogLevelMap[level]}] - {message}";

            // Create write on log file
            if (!File.Exists(setting.LogPath)) FileSystemHelper.NewFile(setting.LogPath);
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

        internal static LogSetting CreateLogSetting2(string logName, string logPath, LogLevel logMinLevel, LogFormat logFormat, bool millisecond, LogDate dateLogName, LogConsole consoleOutput, bool userLogName, bool userLogDir)
        {
            // Log path
            if (string.IsNullOrWhiteSpace(logPath)) logPath = Path.Combine(Environment.CurrentDirectory, "logs");
            else if (!Path.IsPathRooted(logPath)) logPath = Path.GetFullPath(Path.Combine(Environment.CurrentDirectory, logPath));

            // Log name
            logName = string.IsNullOrWhiteSpace(logName) ? "log" : Path.GetFileNameWithoutExtension(logName);

            // Add username in log name
            if (userLogName) logName += $"_{Environment.UserName}";

            // Add Date in log name
            if (dateLogName == LogDate.Date) logName += $"_{DateTime.Now:yyyy-MM-dd}";
            else if (dateLogName == LogDate.Datetime) logName += $"_{DateTime.Now:yyyy-MM-dd_HH-mm-ss}";

            // Extension
            logName += ".log";

            // Full path
            logPath = userLogDir
                ? Path.Combine(logPath, Environment.UserName, logName)
                : Path.Combine(logPath, logName);

            //Return
            return new LogSetting(logPath, logMinLevel, logFormat, consoleOutput, millisecond);
        }
    }
}
