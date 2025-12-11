using NoveLib.Common.Helpers;
using NoveLib.Core;
using NoveLib.Global.Config;
using NoveLib.Global.Constants;
using NoveLib.Global.Context;
using NoveLib.Models;
using System;
using System.IO;
using System.Management.Automation;
using System.Text;
/*
namespace NoveLib.Commands
{
    [Cmdlet(VerbsCommon.New, "CipherKey")]
    public class NewCipherKeyCommand : PSCmdlet
    {
        [Parameter(Position = 0, ParameterSetName = "File")]
        public string Name { get; set; }

        [Parameter(Position = 1, ParameterSetName = "File")]
        public string Path { get; set; }

        [Parameter(Position = 2)]
        public SwitchParameter ToBase64 { get; set; }

        [Parameter(Position = 3)]
        public SwitchParameter Force { get; set; }

        [Parameter(Position = 4)]
        [ValidateSet("128", "192", "256")]
        public string AES { get; set; } = CipherConfig.Keylength;

        protected override void ProcessRecord()
        {
            // Determine key size
            int keyBytesSize = AES switch
            {
                "128" => 16,
                "192" => 24,
                "256" => 32,
                _ => 32,
            };

            // Get other parameters
            bool toBase64 = ToBase64.IsPresent;
            bool force = Force.IsPresent;

            // Generate cipher key bytes
            byte[] keyBytes = CipherCore.CreateCipherKey(keyBytesSize);

            // Create chiper key file
            string keyFile = CipherCore.WriteCipherKeyToFile(keyName, keyPath, keyBytes, toBase64, force);

            // Set as default cipehr key
            CipherContext.KeyFile = keyFile;

            // Output key file
            WriteObject(new FileInfo(keyFile));
        }

        private void NewKey()
        {
            int keyBytesSize = AES switch
            {
                "128" => 16,
                "192" => 24,
                "256" => 32,
                _ => 32,
            };
        }

        private void ProcessFile()
        {
            string keyPath = FileSystemHelper.ResolvePathPS(Path, CipherConstant.CipherDir, this);
            string keyName = Name ?? AES switch
            {
                "128" => "AES128",
                "192" => "AES192",
                "256" => "AES256",
                _ => "AES256",
            };
        }
    }



    [Cmdlet(VerbsCommon.Get, "DefaultCipherKey")]
    public class GetDefaultCipherKeyCommand : PSCmdlet
    {
        protected override void ProcessRecord()
        {
            // Output the key file
            if (CipherContext.KeyFile == null) return;
            else WriteObject(new FileInfo(CipherContext.KeyFile));
        }
    }



    [Cmdlet(VerbsCommon.Set, "DefaultCipherKey")]
    public class SetDefaultCipherKeyCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public string Key { get; set; }

        protected override void ProcessRecord()
        {
            // Check that the key file exists
            if (!File.Exists(Key))
                throw new FileNotFoundException("Specified key file does not exist. Please provide a key path or generate a new one using New-CipherKey -SetDefault.", Key);

            // Set the default global key
            CipherContext.KeyFile = Key;

            // Optional informational message -Verbose
            WriteVerbose($"Default cipher key set to: {Key}");
        }
    }



    [Cmdlet(VerbsSecurity.Protect, "Text")]
    public class ProtectTextCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public string InputString { get; set; }

        [Parameter(Position = 1)]
        public string OutFile { get; set; }

        [Parameter(Position = 3)]
        public string Key { get; set; }

        [Parameter(Position = 4)]
        public SwitchParameter ToBase64 { get; set; }

        protected override void ProcessRecord()
        {
            // Determine cipher key file
            string keyFile = Key ?? CipherContext.KeyFile
                ?? throw new InvalidOperationException(
                    "Default Cipher Key is not set. Please provide a key path or generate a new one using New-CipherKey -SetDefault."
                    );

            // Validate key file existence
            if (!File.Exists(keyFile))
                throw new FileNotFoundException($"Cipher key file not found. Path: {keyFile}", keyFile);

            if (string.IsNullOrWhiteSpace(OutFile) && !File.Exists(OutFile))
            {
                string outPath = Path.GetDirectoryName(OutFile);
                if (!Directory.Exists(outPath))
                    Directory.CreateDirectory(outPath);
            }
            else
            {
                string outPath = FileSystemHelper.ResolvePathPS(null, CipherConstant.AuthDir, this);
                //string outName = 
            }


                // Get other parameters
                bool toBase64 = ToBase64.IsPresent;

            // Read key and encrypt input string
            byte[] keyBytes = CipherCore.ReadCipherKeyFromFile(keyFile);
            byte[] encryptedBytes = CipherCore.EncryptToBytes(InputString, keyBytes);


            // Determinate output type
            object output = toBase64 ? Convert.ToBase64String(encryptedBytes) : encryptedBytes;

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

                // Set text file in read only
                File.SetAttributes(textFile, FileAttributes.ReadOnly);

                cipherSetting.TextFile = textFile;
                cipherSetting.CipherData = output;
            }

            // Set key file
            //cipherSetting.KeyFile = keyFile.FullName;

            // Set as default if specified
            //if (setDefault) Global.DefaultCipherSetting = cipherSetting;

            // Return cipher setting
            WriteObject(cipherSetting);
        }
    }
}
*/