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
            string before = logLine.Substring(0, levelIndex);
            string after = logLine.Substring(levelIndex + level.Length);

            Console.Write(before);
            Console.ForegroundColor = LogMapping.LogColorMap[logLevel];
            Console.Write(level);
            Console.ResetColor();
            Console.WriteLine(after);
        }
    }
}
