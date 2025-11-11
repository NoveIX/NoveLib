using System;
using System.IO;
using System.Text;

namespace NoveLib.Source.Common.Helpers
{
    internal class FileHelper
    {
        internal static void NewFile(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentNullException(nameof(path), $"The {path} cannot be null or empty.");

            var directory = Path.GetDirectoryName(path);
            if (!Directory.Exists(directory) && !string.IsNullOrEmpty(directory)) Directory.CreateDirectory(directory);

            File.Create(path).Dispose();
        }

        internal static void AppendText(string path, string content, string sourceContext)
        {
            try
            {
                using StreamWriter sw = new(path, append: true, encoding: Encoding.UTF8);
                sw.WriteLine(content);
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine($"[{sourceContext}] Error writing to file: {ex.Message}");
                Console.ResetColor();
            }
        }
    }
}
