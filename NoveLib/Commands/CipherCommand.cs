using NoveLib.Common.Helpers;
using NoveLib.Core;
using NoveLib.Global.Config;
using NoveLib.Global.Context;
using NoveLib.Models;
using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Security.Cryptography;
using System.Text;

namespace NoveLib.Commands
{
    [Cmdlet(VerbsCommon.New, "CipherKey")]
    public class NewCipherKeyCommand : PSCmdlet
    {
        [Parameter(Position = 0)]
        public string Name { get; set; }

        [Parameter(Position = 1)]
        public string Path { get; set; }

        [Parameter(Position = 2)]
        [ValidateSet("128", "192", "256")]
        public string AES { get; set; } = CipherConfig.Keylength;

        [Parameter(Position = 2)]
        public SwitchParameter ToBase64 { get; set; }

        [Parameter(Position = 3)]
        public SwitchParameter Force { get; set; }

        [Parameter(Position = 4)]
        public SwitchParameter SetDefault { get; set; }

        [Parameter(Position = 5)]
        public SwitchParameter SetHidden { get; set; }

        protected override void ProcessRecord()
        {
            // Handle cipher key path and name
            string keyPath = FileSystemHelper.ResolvePathPS(Path, "cred", this);
            string keyName = FileSystemHelper.ResolveNamePS(Name, "AES256", this);

            // Get other parameters
            bool toBase64 = ToBase64.IsPresent;
            bool force = Force.IsPresent;
            bool setDefault = SetDefault.IsPresent;
            bool setHidden = SetHidden.IsPresent;

            // Generate cipher key bytes
            byte[] keyBytes = CipherCore.CreateCipherKey();

            // Create chiper key file
            string keyFile = CipherCore.WriteCipherKeyToFile(keyName, keyPath, keyBytes, toBase64, force, setHidden);

            // Set as default if specified
            if (setDefault) CipherContext.Key = keyFile;

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
                throw new FileNotFoundException("Specified key file does not exist. Please provide a key path or generate a new one using New-CipherKey -SetDefault.", Key);

            // Set the default global key
            CipherContext.Key = Key;

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
        public SwitchParameter ToBase64 { get; set; }

        [Parameter(Position = 5)]
        public SwitchParameter SetDefault { get; set; }

        protected override void ProcessRecord()
        {
            // Determine cipher key file
            string keyFile = Key ?? CipherContext.Key
                ?? throw new InvalidOperationException(
                    "Default Cipher Key is not set. Please provide a key path or generate a new one using New-CipherKey -SetDefault."
                    );

            // Validate key file existence
            if (!File.Exists(keyFile))
                throw new FileNotFoundException($"Cipher key file not found. Path: {keyFile}", keyFile);

            // Read key and encrypt input string
            byte[] keyBytes = CipherCore.ReadCipherKeyFromFile(keyFile);
            byte[] encryptedBytes = CipherCore.EncryptToBytes(InputString, keyBytes);

            // Get other parameters
            bool asBase64 = ToBase64.IsPresent;
            bool setDefault = SetDefault.IsPresent;

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

                // Set text file in read only
                File.SetAttributes(textFile, FileAttributes.ReadOnly);

                cipherSetting.TextFile = textFile;
                cipherSetting.CipherData = output;
            }

            // Set key file
            cipherSetting.KeyFile = keyFile;

            // Set as default if specified
            if (setDefault) Global.DefaultCipherSetting = cipherSetting;

            // Return cipher setting
            WriteObject(cipherSetting);
        }
    }

    // ================================================================

    /*
    [Cmdlet(VerbsSecurity.Unprotect, "Text")]
    public class UnprotectTextCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "File")]
        public string TextFile { get; set; }

        [Parameter(Position = 1, ParameterSetName = "File")]
        public string Key { get; set; }

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ParameterSetName = "Cipher")]
        public CipherSetting CipherSetting { get; set; }

        protected override void BeginProcessing()
        {
            // Determine cipher key file
            string keyFile = Key ?? Global.DefaultCipherKey
                ?? throw new InvalidOperationException(
                    "Default Cipher Key is not set. Please provide a Key path or set a default one using New-CipherKey -SetDefault."
                    );

            // Validate key file existence
            if (!File.Exists(keyFile))
                throw new FileNotFoundException("Cipher key file not found.", keyFile);
        }
    }
    */
    [Cmdlet(VerbsSecurity.Unprotect, "Text")]
    public class UnprotectTextCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "File")]
        public string TextFile { get; set; }

        [Parameter(Position = 1, ParameterSetName = "File")]
        public string Key { get; set; }

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ParameterSetName = "Cipher")]
        public CipherSetting CipherSetting { get; set; }

        [Parameter()]
        public SwitchParameter InputIsBase64 { get; set; }

        protected override void BeginProcessing()
        {
            // Determina file della chiave
            string keyFile;

            if (ParameterSetName == "File")
            {
                keyFile = Key ?? CipherContext.Key
                    ?? throw new InvalidOperationException(
                        "Default Cipher Key is not set. Please provide a Key path or set a default one using New-CipherKey -SetDefault."
                    );

                if (!File.Exists(keyFile))
                    throw new FileNotFoundException("Cipher key file not found.", keyFile);
            }
            else // ParameterSetName == "Cipher"
            {
                if (CipherSetting == null)
                    throw new InvalidOperationException("CipherSetting cannot be null.");
                if (!File.Exists(CipherSetting.KeyFile))
                    throw new FileNotFoundException("Cipher key file not found.", CipherSetting.KeyFile);

                keyFile = CipherSetting.KeyFile;
            }

            _keyFile = keyFile; // campo privato della classe per ProcessRecord
        }

        private string _keyFile;

        protected override void ProcessRecord()
        {
            byte[] keyBytes = File.ReadAllBytes(_keyFile);
            byte[] cipherBytes;

            if (ParameterSetName == "File")
            {
                if (InputIsBase64)
                {
                    string base64 = File.ReadAllText(TextFile, Encoding.UTF8);
                    cipherBytes = Convert.FromBase64String(base64);
                }
                else
                {
                    cipherBytes = File.ReadAllBytes(TextFile);
                }
            }
            else
            {
                cipherBytes = CipherSetting.CipherData switch
                {
                    byte[] b => b,
                    string s when InputIsBase64 => Convert.FromBase64String(s),
                    string s => Encoding.UTF8.GetBytes(s),
                    _ => throw new InvalidOperationException("Unsupported CipherData type in CipherSetting")
                };
            }

            string plainText = DecryptFromBytes(cipherBytes, keyBytes);

            if (ParameterSetName == "File" && !string.IsNullOrWhiteSpace(TextFile))
            {
                string outputPath = FileSystemHelper.ResolvePathPS(TextFile, "decrypted", this);
                File.WriteAllText(outputPath, plainText, Encoding.UTF8);
                WriteObject(outputPath);
            }
            else
            {
                WriteObject(plainText);
            }
        }

        private string DecryptFromBytes(byte[] cipherText, byte[] key)
        {
            using var aes = Aes.Create();
            aes.Key = key;

            // Primi 16 byte come IV
            byte[] iv = cipherText.Take(16).ToArray();
            byte[] actualCipher = cipherText.Skip(16).ToArray();
            aes.IV = iv;

            using var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
            using var ms = new MemoryStream(actualCipher);
            using var cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read);
            using var reader = new StreamReader(cs, Encoding.UTF8);

            return reader.ReadToEnd();
        }
    }

}
