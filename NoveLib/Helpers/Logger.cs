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
        TRACE,
        DEBUG,
        INFO,
        WARN,
        ERROR,
        FATAL,
        DONE
    }

    public static class Logger
    {
        private static readonly Dictionary<string, string> LogTimeFormat = new()
        {
            ["Time"] = "HH:mm:ss",
            ["Datetime"] = "yyyy-MM-dd HH:mm:ss"
        };

        private static readonly Dictionary<string, (bool text, bool time)> LogConsoleOutput = new()
                        {
                ["None"] = (text: false, time: false),
                ["Message"] = (text: true, time: false),
                ["MessageAndTime"] = (text: true, time: true)
            };

    // Console color log map
    private static readonly Dictionary<LogLevel, ConsoleColor> LogColorMap = new()
        {
            [LogLevel.TRACE] = ConsoleColor.DarkGray,
            [LogLevel.DEBUG] = ConsoleColor.Gray,
            [LogLevel.INFO] = ConsoleColor.DarkCyan,
            [LogLevel.WARN] = ConsoleColor.DarkYellow,
            [LogLevel.ERROR] = ConsoleColor.Red,
            [LogLevel.FATAL] = ConsoleColor.DarkRed,
            [LogLevel.DONE] = ConsoleColor.Green,
        };

        // Write log in console and only level is colored
        internal static void ConsoleWriteLog(LogLevel logLevel, string message)
        {
            Console.Write("[");
            Console.ForegroundColor = LogColorMap[logLevel];
            Console.Write(logLevel);
            Console.ResetColor();
            Console.WriteLine($"] - {message}");
        }

        internal static void WriteLog(string message, LogLevel logLevel, LogSetting logSetting, bool print, bool printTime)
        {
            // Compare the two levels and return
            if (logLevel < logSetting.LogMinLevel) return;

            // Definition logSetting
            string logPath = logSetting.LogPath;
            string logFormat = logSetting.LogFormat;
            string consoleOutput = logSetting.ConsoleOutput;
            bool useMillisecond = logSetting.UseMillisecond;

            // Define log format
            string logTimeFormat = LogTimeFormat[logFormat];
            if (useMillisecond) logTimeFormat = logTimeFormat + ".fff";

            // Get time now
            string timeStamp = DateTime.Now.ToString(logTimeFormat);

            // Define console output
            var consoleConfig = LogConsoleOutput[consoleOutput];
            bool printMsg = consoleConfig.text || print;
            bool printMsgTime = consoleConfig.time || printTime;

            if (printMsg)
            {
                if (printMsgTime) Console.Write($"[{timeStamp}] ");
                ConsoleWriteLog(logLevel, message);
            }



            // Compose final log line
            string logLine = $"[{timeStamp}] [{logLevel}] - {message}";

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
                Console.Error.WriteLine($"Error while writing to log file: {ex.Message}");
            }
        }
    }
}
