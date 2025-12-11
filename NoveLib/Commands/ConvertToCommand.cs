using NoveLib.Global.Config;
using System.Management.Automation;

namespace NoveLib.Commands
{
    [Cmdlet(VerbsData.ConvertTo, "ReadableByteSize")]
    public class ConvertToReadableByteSizeCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        [ValidateRange(0, long.MaxValue)]
        public long Byte { get; set; }

        [Parameter(Position = 1)]
        [ValidateRange(0, 10)]
        public int DecimalPlace { get; set; } = GenericConfig.DecimalPlace;

        protected override void ProcessRecord()
        {
            
        }
    }
}
