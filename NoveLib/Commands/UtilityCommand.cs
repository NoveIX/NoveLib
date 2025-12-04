using System.IO;
using System.Management.Automation;
using System.Text;

namespace NoveLib.Commands
{
    [Cmdlet(VerbsCommon.Find, "NonAsciiCharacter")]
    public class FindNonAsciiCharacterCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateNotNullOrEmpty]
        public string Path { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "String",
            ValueFromPipeline = true,
            Position = 0)]
        [ValidateNotNullOrEmpty]
        public string InputString { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

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

    // ================================================================
    /*
    [Cmdlet(VerbsCommon.Find, "NetIP")]
    public class FindNetIPCommand : PSCmdlet
    {
        // ParameterSet: solo NetworkCIDR
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "NetworkCIDR")]
        public string NetworkCIDR { get; set; }

        // ParameterSet: Network + Subnet
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "NetworkWithSubnet")]
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "NetworkWithCIDR")]
        public IPAddress Network { get; set; }

        [Parameter(Mandatory = true, Position = 1, ParameterSetName = "NetworkWithSubnet")]
        public IPAddress Subnet { get; set; }

        [Parameter(Mandatory = true, Position = 1, ParameterSetName = "NetworkWithCIDR")]
        public int CIDR { get; set; }

        protected override void ProcessRecord()
        {
            // Calcolo Network e CIDR se viene passato NetworkCIDR
            switch (ParameterSetName)
            {
                case "NetworkCIDR":
                    var parts = NetworkCIDR.Split('/');
                    Network = IPAddress.Parse(parts[0]);
                    CIDR = int.Parse(parts[1]);
                    Subnet = GetSubnetFromCIDR(CIDR);
                    break;

                case "NetworkWithSubnet":
                    CIDR = GetCIDRFromSubnet(Subnet);
                    break;

                case "NetworkWithCIDR":
                    Subnet = GetSubnetFromCIDR(CIDR);
                    break;
            }

            WriteObject($"Calcolo gli IP della rete {Network}/{CIDR}...");

            var ips = GetIPRange(Network, CIDR);
            WriteObject($"Trovati {ips.Count} IP da testare.\n");

            var used = new List<string>();
            var free = new List<string>();
            object lockObj = new object();

            // Parallel.ForEach con limite thread
            ParallelOptions options = new ParallelOptions { MaxDegreeOfParallelism = 50 };
            Parallel.ForEach(ips, options, ip =>
            {
                bool alive = PingHost(ip);

                lock (lockObj)
                {
                    if (alive)
                    {
                        WriteObject($"{ip} IN USO");
                        used.Add(ip);
                    }
                    else
                    {
                        WriteObject($"{ip} libero");
                        free.Add(ip);
                    }
                }
            });

            WriteObject("\n--- RISULTATI ---");
            WriteObject("\nIP IN USO:");
            used.ForEach(u => WriteObject(u));

            WriteObject("\nIP LIBERI:");
            free.ForEach(f => WriteObject(f));

            WriteObject(new
            {
                Used = used,
                Free = free,
                Network,
                Subnet,
                CIDR,
                NetworkCIDR = $"{Network}/{CIDR}"
            });
        }

        private List<IPAddress> GetIPRange(IPAddress network, int cidr)
        {
            var bytes = network.GetAddressBytes();
            Array.Reverse(bytes);
            uint baseIP = BitConverter.ToUInt32(bytes, 0);

            uint hostCount = (uint)Math.Pow(2, 32 - cidr);
            var list = new List<IPAddress>();

            for (uint i = 1; i < hostCount - 1; i++) // skip network e broadcast
            {
                uint current = baseIP + i;
                byte[] b = BitConverter.GetBytes(current);
                Array.Reverse(b);
                list.Add(new IPAddress(b));
            }
            return list;
        }

        private IPAddress GetSubnetFromCIDR(int cidr)
        {
            uint mask = 0xFFFFFFFF;
            mask <<= (32 - cidr);
            byte[] bytes = new byte[4];
            bytes[0] = (byte)((mask >> 24) & 0xFF);
            bytes[1] = (byte)((mask >> 16) & 0xFF);
            bytes[2] = (byte)((mask >> 8) & 0xFF);
            bytes[3] = (byte)(mask & 0xFF);
            return new IPAddress(bytes);
        }

        private int GetCIDRFromSubnet(IPAddress subnet)
        {
            var bytes = subnet.GetAddressBytes();
            int cidr = 0;
            foreach (var b in bytes)
            {
                for (int i = 7; i >= 0; i--)
                {
                    if ((b & (1 << i)) != 0) cidr++;
                }
            }
            return cidr;
        }

        private bool PingHost(IPAddress ip)
        {
            try
            {
                using (Ping p = new Ping())
                {
                    var reply = p.Send(ip, 1000);
                    return reply.Status == IPStatus.Success;
                }
            }
            catch
            {
                return false;
            }
        }
    } */
}
