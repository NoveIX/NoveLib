using NoveLib.Source.Common.Enums;
using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Common.Mappings;
using NoveLib.Source.Models;
using System;
using System.IO;
using System.Reflection;
using System.Text;

namespace NoveLib.Source.Core
{
    internal class LogManager
    {
        // Create LogSetting object based on parameters
        internal static LogSetting CreateLogSetting(string logName, string logPath, LogLevel logLevel, LogFormat logFormat, LogDate logDate, bool consolePrint, bool setDefault)
        {
            // logPath normalized in Cmdlet
            // logName normalized in Cmdlet

            // Add date to log name
            if (logDate != LogDate.None)
            {
                string format = LogMapping.LogDateMap[logDate];
                logName += $"_{DateTime.Now.ToString(format)}";
            }

            // Add .log extension
            logName += ".log";

            // Combine path and name
            string logFile = Path.Combine(logPath, logName);

            // Create LogSetting object
            return new LogSetting(logFile, logLevel, logFormat, consolePrint, setDefault);
        }

        // ================================================================

        // Write log message to file
        internal static void WriteLog(LogLevel logLevel, string message, LogSetting logSetting, bool print, string sourceContext)
        {
            // Check log level
            if (logLevel < logSetting.LogLevel) return;

            // Get source context
            if (string.IsNullOrWhiteSpace(sourceContext)) sourceContext = MethodBase.GetCurrentMethod().DeclaringType.FullName;

            // Get timestamp
            string timestamp = string.Empty;
            if (logSetting.LogFormat != LogFormat.Simple)
            {
                string format = LogMapping.logFormatMap[logSetting.LogFormat];
                timestamp = DateTime.Now.ToString(format);
            }

            // Compose log line
            string level = LogMapping.logLevelMap[logLevel];
            string logLine = LogMapping.LogLineMap[logSetting.LogFormat] (timestamp, level, sourceContext, message);

            // Print to console if enabled
            if (logSetting.ConsolePrint || print) Console.WriteLine(logLine); //ConsoleHelper.ConsolePrintLogColor(logLevel, logLine);

            // Write to file
            Directory.CreateDirectory(Path.GetDirectoryName(logSetting.LogFile)!);
            FileHelper.AppendText(logSetting.LogFile, logLine, sourceContext);
        }
    }
}
