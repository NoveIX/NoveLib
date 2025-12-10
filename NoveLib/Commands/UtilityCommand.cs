using System.IO;
using System.Management.Automation;
using System.Text;

namespace NoveLib.Commands
{
    [Cmdlet(VerbsCommon.Find, "NonAsciiCharacter")]
    public class FindNonAsciiCharacterCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, ParameterSetName = "Path", Position = 0)]
        public string Path { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = "String", Position = 0, ValueFromPipeline = true)]
        public string InputString { get; set; }

        protected override void ProcessRecord()
        {
            if (ParameterSetName == "Path")
                ProcessFile(Path);
            else
                ProcessString(InputString);
        }

        private void ProcessFile(string path)
        {
            if (!File.Exists(path))
                throw new FileNotFoundException("The specified file does not exist.", path);

            string[] lines = File.ReadAllLines(path, Encoding.UTF8);
            for (int i = 0; i < lines.Length; i++)
                DetectNonAscii(lines[i], i + 1);
        }

        private void ProcessString(string input)
        {
            DetectNonAscii(input, 1);
        }

        private void DetectNonAscii(string text, int line)
        {
            for (int i = 0; i < text.Length; i++)
            {
                char c = text[i];
                if (c > 127)
                    WriteObject($"Line: {line}, position: {i + 1} char: '{c}' code: {(int)c}");
            }
        }
    }
}
