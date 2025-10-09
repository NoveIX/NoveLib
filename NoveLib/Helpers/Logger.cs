using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;

namespace NoveLib.Helpers
{
    /// <summary>
    /// Specifies the severity level of a log message.
    /// </summary>
    public enum LogLevel
    {
        Trace,
        Debug,
        Info,
        Warn,
        Error,
        Fatal,
        Done
    }

    public static class Logger
    {
        // Log format map
        private static readonly Dictionary<string, string> LogTimeFormatMap = new()
        {
            ["Time"] = "HH:mm:ss",
            ["Datetime"] = "yyyy-MM-dd HH:mm:ss"
        };

        // Log console map
        private static readonly Dictionary<string, (bool text, bool time)> ConsoleOutputMap = new()
        {
            ["None"] = (text: false, time: false),
            ["Message"] = (text: true, time: false),
            ["MessageAndTime"] = (text: true, time: true)
        };

        // Log color map
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
        
        // Get time stamp
        private static string GetTimestamp(string format, bool millisecond)
        {
            string logFormat = LogTimeFormatMap[format];
            if (millisecond) logFormat += ".fff";
            return DateTime.Now.ToString(logFormat);
        }

        // Write log in console
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
            // Compare the two levels and return
            if (level < setting.LogMinLevel) return;

            // Scompose log setting
            string logPath = setting.LogPath;
            string logFormat = setting.LogFormat;
            string consoleOutput = setting.ConsoleOutput;
            bool millisecond = setting.Millisecond;

            // Get time stamp
            string timeStamp = GetTimestamp(logFormat, millisecond);

            // Define console output
            var (text, time) = ConsoleOutputMap[consoleOutput];
            bool printMsg = text || print;
            bool printMsgTime = time || printTime;

            if (printMsg)
            {
                if (printMsgTime) Console.Write($"[{timeStamp}] ");
                WriteConsoleLog(level, message);
            }

            // Compose final log line
            string logLine = $"[{timeStamp}] [{level}] - {message}";

            // Ensure log file and write with share
            FileSystemHelper.NewFile(logPath);
            try
            {
                using FileStream fs = new(
                    logPath,
                    FileMode.Append,
                    FileAccess.Write,
                    FileShare.Read);
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
