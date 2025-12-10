using NoveLib.Common.Enums;
using NoveLib.Common.Mappings;
using System;

namespace NoveLib.Common.Helpers
{
    internal class ConsoleHelper
    {
        internal static void LogConsolePrint(LogLevel logLevel, string logLine)
        {
            string level = LogMapping.logLevelMap[logLevel];
            int levelIndex = logLine.IndexOf(level);

            // Split the log line into three parts: before the level, the level itself, and after the level
#if NET6_0_OR_GREATER
            string before = logLine[..levelIndex];
            string after = logLine[(levelIndex + level.Length)..];
#else
            string before = logLine.Substring(0, levelIndex);
            string after = logLine.Substring(levelIndex + level.Length);
#endif

            Console.Write(before);
            Console.ForegroundColor = LogMapping.LogColorMap[logLevel];
            Console.Write(level);
            Console.ResetColor();
            Console.WriteLine(after);
        }
    }
}
