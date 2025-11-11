using NoveLib.Source.Common.Enums;
using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Common.Mappings;
using NoveLib.Source.Models;
using System;
using System.IO;

namespace NoveLib.Source.Core
{
    internal class LogManager
    {
        // Create LogSetting object based on parameters
        internal static LogSetting CreateLogSetting(string logName, string logPath, LogLevel logLevel, LogFormat logFormat, LogDate logDate, bool consolePrint, bool setDefault)
        {
            // Add date to log name
            if (logDate != LogDate.None) logName += $"_{DateTime.Now.ToString(LogMapping.LogDateMap[logDate])}";

            // Add .log extension
            logName += ".log";

            // Combine path and name
            string logFile = Path.Combine(logPath, logName);

            // Create LogSetting object
            return new LogSetting(logFile, logLevel, logFormat, consolePrint, setDefault);
        }

        // ================================================================

        // Write log message to file
        internal static void WriteLog(LogLevel logLevel, string message, LogSetting logSetting, bool print, string context, string file, int line)
        {
            // Check log level
            if (logLevel < logSetting.LogLevel) return;

            // Get timestamp
            string timestamp = string.Empty;
            if (logSetting.LogFormat != LogFormat.Simple) timestamp = DateTime.Now.ToString(LogMapping.logFormatMap[logSetting.LogFormat]);

            // Compose log line
            string logLine = LogMapping.LogLineMap[logSetting.LogFormat] (timestamp, LogMapping.logLevelMap[logLevel], context, message, file, line);

            // Print to console if enabled
            if (logSetting.ConsolePrint || print) Console.WriteLine(logLine);

            // Write to file
            Directory.CreateDirectory(Path.GetDirectoryName(logSetting.LogFile)!);
            FileSystemHelper.AppendText(logSetting.LogFile, logLine);
        }
    }
}
