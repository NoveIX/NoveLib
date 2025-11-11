using System;
using System.IO;
using System.Management.Automation;
using System.Text;

namespace NoveLib.Source.Commands
{
    [Cmdlet(VerbsCommon.Find, "NonAsciiCharacter")]
    public class FindNonAsciiCharacter : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Path { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            string path = Path;

            // Validate path
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentException("The path cannot be empty.", path);
            if (!File.Exists(path)) throw new FileNotFoundException("The specified file does not exist.", path);

            //Read all line
            string[] lines = File.ReadAllLines(path, Encoding.UTF8);
            int lineNumber = 0;
            bool found = false;

            foreach (string line in lines)
            {
                lineNumber++;
                for (int i = 0; i < line.Length; i++)
                {
                    char c = line[i];
                    if (c > 127) // Ascii Charater
                    {
                        Console.WriteLine($"Line: {lineNumber}, position: {i + 1} char: '{c}' code: {(int)c}");
                        found = true;
                    }
                }
            }

            if (!found)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("No non-ASCII characters found.");
                Console.ResetColor();
            }
        }
    }
}
