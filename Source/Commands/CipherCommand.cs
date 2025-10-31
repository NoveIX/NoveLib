using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Security.Cryptography;

namespace NoveLib.Source.Commands
{
    [Cmdlet(VerbsCommon.New, "CipherKey")]
    public class NewCipherKeyCommand : PSCmdlet
    {
        [Parameter(Position = 0)]
        public string Name { get; set; }

        [Parameter(Position = 1)]
        public string Path { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            // Handle cipher key path
            string keyPath = Path;
            string basePath;

            if (string.IsNullOrWhiteSpace(keyPath))
            {
                // Take base path from script location or current location
                basePath = !string.IsNullOrEmpty(MyInvocation.ScriptName)
                    ? System.IO.Path.GetDirectoryName(MyInvocation.ScriptName)
                    : SessionState.Path.CurrentFileSystemLocation.Path;

                // Construct default cipher path
                keyPath = System.IO.Path.Combine(basePath, "cred");
            }
            else if (!System.IO.Path.IsPathRooted(keyPath))
            {
                // Convert to absolute path if relative
                keyPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(
                    SessionState.Path.CurrentFileSystemLocation.Path, keyPath));
            }

            // Handle cipher key name
            string keyName = Name;

            if (string.IsNullOrWhiteSpace(keyName))
            {
                // Get log name from script name or default
                keyName = !string.IsNullOrWhiteSpace(MyInvocation.ScriptName)
                    ? System.IO.Path.GetFileNameWithoutExtension(MyInvocation.ScriptName)
                    : "aeskey"; // Default cipher key name
            }
            else
            {
                // Remove extension if provided
                keyName = System.IO.Path.GetFileNameWithoutExtension(keyName);
            }

            // Sanitize cipher key name
            keyName = string.Concat(keyName.Select(ch => System.IO.Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));

            keyName += ".key";

            byte[] newKey = new byte[32];

            // Use different method to randomize key bytes
#if NET6_0_OR_GREATER
            RandomNumberGenerator.Fill(newKey);
#else
            using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(newKey);
#endif

            // Create directory
            if (!Directory.Exists(keyPath)) Directory.CreateDirectory(keyPath);
            string keyFile = System.IO.Path.Combine(keyPath, keyName);

            // Write key on file
            File.WriteAllBytes(keyFile, newKey);

            // Output key file
            WriteObject(keyFile);
        }
    }

    // ================================================================

    [Cmdlet(VerbsLifecycle.Invoke, "EncryptText")]
    public class EncryptTextCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string KeyPath { get; set; }

        [Parameter(Position = 1)]
        public string Name { get; set; }

        [Parameter(Position = 2)]
        public string Path { get; set; }

        [Parameter(Mandatory = true, Position = 3)]
        public string[] InputText { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            string keyPath = KeyPath;
            if (!File.Exists(keyPath)) throw new FileNotFoundException($"The specified key file was not found: {keyPath}");

            // Handle cipher text path
            string textPath = Path;
            string basePath;

            if (string.IsNullOrWhiteSpace(textPath))
            {
                // Take base path from script location or current location
                basePath = !string.IsNullOrEmpty(MyInvocation.ScriptName)
                    ? System.IO.Path.GetDirectoryName(MyInvocation.ScriptName)
                    : SessionState.Path.CurrentFileSystemLocation.Path;

                // Construct default cipher path
                textPath = System.IO.Path.Combine(textPath, "cred");
            }
            else if (!System.IO.Path.IsPathRooted(textPath))
            {
                // Convert to absolute path if relative
                textPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(
                    SessionState.Path.CurrentFileSystemLocation.Path, textPath));
            }

            // Handle cipher tex name
            string textName = Name;

            if (string.IsNullOrWhiteSpace(textName))
            {
                // Get log name from script name or default
                textName = !string.IsNullOrWhiteSpace(MyInvocation.ScriptName)
                    ? System.IO.Path.GetFileNameWithoutExtension(MyInvocation.ScriptName)
                    : "encrypted text"; // Default cipher text name
            }
            else
            {
                // Remove extension if provided
                textName = System.IO.Path.GetFileNameWithoutExtension(textName);
            }

            // Sanitize cipher text name
            textName = string.Concat(textName.Select(ch => System.IO.Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));
        }
    }
}
