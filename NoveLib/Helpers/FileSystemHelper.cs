using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NoveLib.Helpers
{
    internal static class FileSystemHelper
    {
        internal static void NewDir(string path)
        {
            // Path can not be empty
            if (string.IsNullOrWhiteSpace(path)) { throw new ArgumentNullException(nameof(path), "The path cannot be null or empty."); }

            // Create directory
            if (!Directory.Exists(path)) { Directory.CreateDirectory(path); }
        }

        internal static void NewFile(string path)
        {
            // Create directory if is a path
            string directory = Path.GetDirectoryName(path);
            if (!string.IsNullOrWhiteSpace(directory)) NewDir(directory);

            // Create new file
            if (!File.Exists(path)) File.Create(path).Dispose();
        }
    }
}
