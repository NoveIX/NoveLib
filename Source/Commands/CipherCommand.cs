using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Core;
using System.Management.Automation;

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

        protected override void ProcessRecord()
        {
            // Handle cipher key path and name
            string keyPath = FileSystemHelper.ResolvePathPS(Path, "cred", this);
            string keyName = FileSystemHelper.ResolveFilePS(Name, "aeskey", this);

            // Get other parameters
            bool setDefault = SetDefault.IsPresent;

            // Create chiper key file
            string keyFile = CipherCore.CreateCipherKey(keyName, keyPath);

            // Set as default if specified
            if (setDefault) Global.DefaultCipherKey = keyFile;

            // Output key file
            WriteObject(keyFile);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommon.Set, "DefaultCipherKey")]
    public class SetDefaultCipherKey

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

        protected override void ProcessRecord()
        {
            string keyFile = Key ?? Global.DefaultCipherKey
                ?? throw new PSInvalidOperationException(
                    "Default Cipher Key is not set. Please provide a Key path or set a default one using New-CipherKey -SetDefault."
                    )

            
        }



        private void Encrypt()
        {

        }
    }
    
}
