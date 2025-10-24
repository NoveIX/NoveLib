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
            int levelIndex = logLine.IndexOf(logLevel.ToString(), StringComparison.OrdinalIgnoreCase);

            if (levelIndex >= 0)
            {
                Console.Write(logLine[..levelIndex]);

                // Cambia colore per il livello
                Console.ForegroundColor = LogMapping.LogColorMap[level];
                Console.Write(levelText);

                // Ripristina colore e scrivi il resto
                Console.ForegroundColor = originalColor;
                Console.WriteLine(logLine[(levelIndex + levelText.Length)..]);
            }
        }
    }
}
