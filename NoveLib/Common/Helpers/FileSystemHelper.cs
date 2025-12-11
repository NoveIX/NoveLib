using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text;

namespace NoveLib.Common.Helpers
{
    internal class FileSystemHelper
    {
        internal static string ResolvePathPS(string path, string dir, PSCmdlet cmdlet)
        {
            // Get current directory
            string pwd = cmdlet.SessionState.Path.CurrentFileSystemLocation.Path;

            if (string.IsNullOrWhiteSpace(path))
            {
                // Get script name
                string psFile = cmdlet.MyInvocation.ScriptName;

                // Use script directory or current dir
                string basePath = !string.IsNullOrEmpty(psFile)
                    ? Path.GetDirectoryName(psFile)
                    : pwd;

                // Combine with default dir
                path = Path.Combine(basePath, dir);
            }

            // Convert to absolute path if relative
            else if (!Path.IsPathRooted(path)) path = Path.GetFullPath(Path.Combine(pwd, path));

            return path;
        }

        internal static string ResolveNamePS(string file, string name, PSCmdlet cmdlet)
        {
            if (string.IsNullOrWhiteSpace(file))
            {
                // Get script name
                string psFile = cmdlet.MyInvocation.ScriptName;

                // Use script name or default name
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
