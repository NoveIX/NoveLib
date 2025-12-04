using NoveLib.Core;
using System.Management.Automation;
using System.Net;

namespace NoveLib.Commands
{
    public class NetworkCommand
    {
        [Cmdlet(VerbsData.Convert, "CidrToMask")]
        public class ConvertCidrToMaskCommand : PSCmdlet
        {
            [Parameter(Mandatory = true, Position = 0)]
            public int CIDR { get; set; }

            public SwitchParameter IPv6 { get; set; }

            protected override void ProcessRecord()
            {
                IPAddress mask;
                bool isIpv6 = IPv6.IsPresent;

                // Convert CIDR to subnet mask
                if (isIpv6) mask = NetworkCore.CidrToMaskIPv6(CIDR);
                else mask = NetworkCore.CidrToMaskIPv4(CIDR);

                // Output the result
                WriteObject(mask.ToString());
            }
        }

        [Cmdlet(VerbsData.Convert, "MaskToCidr")]
        public class ConvertMaskToCidrCommand : PSCmdlet
        {
            [Parameter(Mandatory = true, Position = 0)]
            public IPAddress Subnet { get; set; }

            public SwitchParameter IPv6 { get; set; }

            protected override void ProcessRecord()
            {
                int cidr;
                bool isIpv6 = IPv6.IsPresent;

                // Convert subnet mask to CIDR
                if (isIpv6) cidr = NetworkCore.MaskToCidrIPv6(Subnet);
                else cidr = NetworkCore.MaskToCidrIPv4(Subnet);

                // Output the result
                WriteObject(cidr);
            }
        }
    }
}
