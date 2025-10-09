using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Text;

namespace NoveLib.Helpers
{
    public enum LogLevel
    {
        Trace, Debug, Info, Warn, Error, Fatal, Done
    }

    public static class Logger
    {
        private static readonly Dictionary<string, string> LogTimeFormatMap = new()
        {
            ["Time"] = "HH:mm:ss",
            ["Datetime"] = "yyyy-MM-dd HH:mm:ss"
        };

        private static readonly Dictionary<string, (bool text, bool time)> ConsoleOutputMap = new()
        {
            ["None"] = (false, false),
            ["Message"] = (true, false),
            ["MessageAndTime"] = (true, true)
        };

        private static readonly Dictionary<LogLevel, ConsoleColor> LogLevelColorMap = new()
        {
            [LogLevel.Trace] = ConsoleColor.DarkGray,
            [LogLevel.Debug] = ConsoleColor.Gray,
            [LogLevel.Info] = ConsoleColor.DarkCyan,
            [LogLevel.Warn] = ConsoleColor.DarkYellow,
            [LogLevel.Error] = ConsoleColor.Red,
            [LogLevel.Fatal] = ConsoleColor.DarkRed,
            [LogLevel.Done] = ConsoleColor.Green,
        };

        private static string GetTimestamp(string format, bool millisecond)
        {
            string logFormat = LogTimeFormatMap[format];
            if (millisecond) logFormat += ".fff";
            return DateTime.Now.ToString(logFormat);
        }

        internal static void WriteConsoleLog(LogLevel level, string message)
        {
            Console.Write("[");
            Console.ForegroundColor = LogLevelColorMap[level];
            Console.Write(level);
            Console.ResetColor();
            Console.WriteLine($"] - {message}");
        }

        internal static void WriteLog(LogLevel level, string message, LogSetting setting, bool print, bool printTime)
        {
            // Log guard
            if (level < setting.LogMinLevel) return;

            // Scompose setting
            string logPath = setting.LogPath;
            string logFormat = setting.LogFormat;
            string consoleOutput = setting.ConsoleOutput;
            bool millisecond = setting.Millisecond;

            // Get timestamp
            string timeStamp = GetTimestamp(logFormat, millisecond);

            // Console print
            var (text, time) = ConsoleOutputMap[consoleOutput];
            bool printMsg = text || print;
            if (printMsg)
            {
                bool printMsgTime = time || printTime;
                if (printMsgTime) Console.Write($"[{timeStamp}] ");
                WriteConsoleLog(level, message);
            }
            
            // Construct log line
            StringBuilder sb = new StringBuilder();
            string logLine = sb
                .Append('[')
                .Append(timeStamp)
                .Append("] [")
                .Append(level)
                .Append("] - ")
                .Append(message)
                .ToString();

            // Create write on log file
            if (!File.Exists(logPath)) FileSystemHelper.NewFile(logPath);
            try
            {
                using FileStream fs = new(logPath, FileMode.Append, FileAccess.Write, FileShare.Read);
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
    }
}
