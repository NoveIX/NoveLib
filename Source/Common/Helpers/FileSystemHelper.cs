using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text;

namespace NoveLib.Source.Common.Helpers
{
    internal class FileSystemHelper
    {
        internal static string ResolvePathPS(string path, string dir, PSCmdlet cmdlet)
        {
            string psFile = cmdlet.MyInvocation.ScriptName;
            string whereAmI = cmdlet.SessionState.Path.CurrentFileSystemLocation.Path;

            if (string.IsNullOrWhiteSpace(path))
            {
                // Take base path from script location or current location
                string basePath = !string.IsNullOrEmpty(psFile)
                    ? Path.GetDirectoryName(psFile)
                    : whereAmI;

                // Construct default log path
                path = Path.Combine(basePath, dir);
            }

            // Convert to absolute path if relative
            else if (!Path.IsPathRooted(path)) path = Path.GetFullPath(Path.Combine(whereAmI, path));

            return path;
        }

        internal static string ResolveFilePS(string file, string name, PSCmdlet cmdlet)
        {
            string psFile = cmdlet.MyInvocation.ScriptName;

            if (string.IsNullOrWhiteSpace(file))
            {
                // Get log name from script name or default
                file = !string.IsNullOrWhiteSpace(psFile)
                    ? Path.GetFileNameWithoutExtension(psFile)
                    : name; // Default name
            }

            // Remove extension if provided
            else file = Path.GetFileNameWithoutExtension(file);

            // Sanitize log name
            file = string.Concat(file.Select(ch => Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));

            return file;
        }

        internal static void AppendText(string path, string text)
        {
            try
            {
                using StreamWriter sw = new(path, append: true, encoding: Encoding.UTF8);
                sw.WriteLine(text);
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine($"[{MethodBase.GetCurrentMethod().DeclaringType.FullName}] Error writing to file: {ex.Message}");
                Console.ResetColor();
            }
        }
    }
}
