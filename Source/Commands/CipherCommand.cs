using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Core;
using NoveLib.Source.Models;
using System;
using System.IO;
using System.Management.Automation;
using System.Text;

namespace NoveLib.Source.Commands
{
    [Cmdlet(VerbsCommon.New, "CipherKey")]
    public class NewCipherKeyCommand : PSCmdlet
    {
        [Parameter(Position = 0)]
        public string Name { get; set; }

        [Parameter(Position = 1)]
        public string Path { get; set; }

        [Parameter(Position = 2)]
        public SwitchParameter SetDefault { get; set; }

        [Parameter(Position = 3)]
        public SwitchParameter HideKey { get; set; }

        protected override void ProcessRecord()
        {
            // Handle cipher key path and name
            string keyPath = FileSystemHelper.ResolvePathPS(Path, "cred", this);
            string keyName = FileSystemHelper.ResolveNamePS(Name, "aeskey", this);

            // Get other parameters
            bool setDefault = SetDefault.IsPresent;
            bool hideKey = HideKey.IsPresent;

            // Create chiper key file
            string keyFile = CipherCore.CreateCipherKey(keyName, keyPath, hideKey);

            // Set as default if specified
            if (setDefault) Global.DefaultCipherKey = keyFile;

            // Output key file
            WriteObject(keyFile);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommon.Set, "DefaultCipherKey")]
    public class SetDefaultCipherKeyCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public string Key { get; set; }

        protected override void ProcessRecord()
        {
            // Check that the key file exists
            if (!File.Exists(Key))
                throw new FileNotFoundException("Specified key file does not exist.", Key);

            // Set the default global key
            Global.DefaultCipherKey = Key;

            // Optional informational message -Verbose
            WriteVerbose($"Default cipher key set to: {Key}");
        }
    }

    // ================================================================

    [Cmdlet(VerbsSecurity.Protect, "Text")]
    public class ProtectTextCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public string InputString { get; set; }

        [Parameter(Position = 1)]
        public string Name { get; set; }

        [Parameter(Position = 2)]
        public string Path { get; set; }

        [Parameter(Position = 3)]
        public string Key { get; set; }

        [Parameter(Position = 4)]
        public SwitchParameter AsBase64 { get; set; }

        protected override void ProcessRecord()
        {
            // Determine cipher key file
            string keyFile = Key ?? Global.DefaultCipherKey
                ?? throw new InvalidOperationException(
                    "Default Cipher Key is not set. Please provide a Key path or set a default one using New-CipherKey -SetDefault."
                    );

            // Validate key file existence
            if (!File.Exists(keyFile))
                throw new FileNotFoundException("Cipher key file not found.", keyFile);

            // Read key and encrypt input string
            byte[] keyBytes = File.ReadAllBytes(keyFile);
            byte[] encryptedBytes = CipherCore.EncryptToBytes(InputString, keyBytes);

            // Get other parameters
            bool asBase64 = AsBase64.IsPresent;

            // Determinate output type
            object output = asBase64 ? Convert.ToBase64String(encryptedBytes) : encryptedBytes;

            // Create new empty cipher Setting
            CipherSetting cipherSetting = new();

            if (string.IsNullOrWhiteSpace(Name))
                cipherSetting.CipherData = output;
            else
            {
                // Handle text path and name
                string textPath = FileSystemHelper.ResolvePathPS(Path, "cred", this);
                string textName = FileSystemHelper.ResolveNamePS(Name, "text", this);
                string textFile = System.IO.Path.Combine(textPath, textName);

                // Ensure dir exists
                if (!Directory.Exists(textPath))
                    Directory.CreateDirectory(textPath);

                // Write output on file
                if (asBase64)
                    File.WriteAllText(textFile, (string)output, Encoding.UTF8);
                else
                    File.WriteAllBytes(textFile, (byte[])output);

                File.SetAttributes(textFile, FileAttributes.ReadOnly);

                cipherSetting.TextFile = textFile;
                cipherSetting.CipherData = output;
            }

            // 
            WriteObject(cipherSetting);
        }
    }

    // ================================================================

    [Cmdlet(VerbsSecurity.Unprotect, "Text")]
    public class UnprotectTextCommand : PSCmdlet
    { }
}
