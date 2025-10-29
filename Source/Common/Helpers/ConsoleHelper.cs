using NoveLib.Source.Common.Enums;
using NoveLib.Source.Common.Mappings;
using System;
using System.Reflection.Emit;

namespace NoveLib.Source.Common.Helpers
{
    internal class ConsoleHelper
    {
        internal static void ConsolePrintLogColor(LogLevel logLevel, string logLine)
        {
            var originalColor = Console.ForegroundColor;

            string levelText = logLevel.ToString();
            int index = logLine.IndexOf(levelText, StringComparison.OrdinalIgnoreCase);

            if (index == -1)
            {
                Console.WriteLine(logLine);
                return;
            }

            string before = logLine.Substring(0, index);
            string levelPart = logLine.Substring(index, levelText.Length);
            string after = logLine.Substring(index + levelText.Length);

            Console.Write(before);

            if (LogMapping.LogColorMap.TryGetValue(logLevel, out var color))
                Console.ForegroundColor = color;

            Console.Write(levelPart);

            Console.ForegroundColor = originalColor;
            Console.WriteLine(after);
        }

    }
}
