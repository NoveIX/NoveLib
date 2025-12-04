using NoveLib.Source.Common.Enums;
using System;
using System.Collections.Generic;

namespace NoveLib.Source.Common.Mappings
{
    internal class LogMapping
    {
        internal static readonly Dictionary<LogLevel, string> logLevelMap = new()
        {
            [LogLevel.Trace] = "TRACE",
            [LogLevel.Debug] = "DEBUG",
            [LogLevel.Info] = "INFO",
            [LogLevel.Warn] = "WARN",
            [LogLevel.Error] = "ERROR",
            [LogLevel.Fatal] = "FATAL",
            [LogLevel.Done] = "DONE"
        };

        internal static readonly Dictionary<LogDate, string> LogDateMap = new()
        {
            //[LogDate.None] = "",
            [LogDate.DateCompact] = "yyyyMMdd",
            [LogDate.DateHyphen] = "yyyy-MM-dd",
            [LogDate.DateTimeCompact] = "yyyyMMdd_HHmmss",
            [LogDate.DateTimeHyphen] = "yyyy-MM-dd_HH-mm-ss",
        };

        internal static readonly Dictionary<LogFormat, string> logFormatMap = new()
        {
            [LogFormat.Default] = "yyyy-MM-dd HH:mm:ss",
            //[LogFormat.Simple] = "",
            [LogFormat.Detailed] = "yyyy-MM-dd HH:mm:ss.fff",
            [LogFormat.Compact] = "HH:mm:ss",
            [LogFormat.ISO8601] = "yyyy-MM-ddTHH:mm:ss.fffzzz",
            [LogFormat.Verbose] = "yyyy-MM-dd HH:mm:ss.fff zzz"
        };

        internal static readonly Dictionary<LogFormat, Func<string, string, string, string, string, int, string>> LogLineMap = new()
        {
            [LogFormat.Default] = (timestamp, level, _, message, _, _) => $"[{timestamp}] [{level}]: {message}",
            [LogFormat.Simple] = (_, level, _, message, _, _) => $"[{level}]: {message}",
            [LogFormat.Detailed] = (timestamp, level, context, message, _, _) => $"[{timestamp}] [{level}] [{context}]: {message}",
            [LogFormat.Compact] = (timestamp, level, _, message, _, _) => $"{timestamp} {level}: {message}",
            [LogFormat.ISO8601] = (timestamp, level, context, message, _, _) => $"[{timestamp}] [{level}] [{context}]: {message}",
            [LogFormat.Verbose] = (timestamp, level, context, message, file, line) => $"[{timestamp}] [{level}] [{context}] [{file}:{line}]: {message}"
        };

        internal static readonly Dictionary<LogLevel, ConsoleColor> LogColorMap = new()
        {
            [LogLevel.Trace] = ConsoleColor.DarkGray,
            [LogLevel.Debug] = ConsoleColor.Gray,
            [LogLevel.Info] = ConsoleColor.DarkCyan,
            [LogLevel.Warn] = ConsoleColor.DarkYellow,
            [LogLevel.Error] = ConsoleColor.Red,
            [LogLevel.Fatal] = ConsoleColor.DarkRed,
            [LogLevel.Done] = ConsoleColor.Green,
        };
    }
}
