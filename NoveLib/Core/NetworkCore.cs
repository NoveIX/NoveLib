
using System;
using System.Net;

namespace NoveLib.Core
{
    internal class NetworkCore
    {
        internal static IPAddress CidrToMaskIPv4(int cidr)
        {
            if (cidr is < 0 or > 32) throw new ArgumentOutOfRangeException(nameof(cidr), "CIDR IPv4 must be between 0 and 32");

            byte[] mask = new byte[4];

            int fullBytes = cidr / 8;
            int remainingBits = cidr % 8;

            // Full bytes
            for (int i = 0; i < fullBytes; i++) mask[i] = 0xFF;

            // Partial byte
            if (remainingBits > 0) mask[fullBytes] = (byte)(0xFF << (8 - remainingBits));

            return new IPAddress(mask);
        }

        internal static IPAddress CidrToMaskIPv6(int cidr)
        {
            if (cidr < 0 || cidr > 128) throw new ArgumentOutOfRangeException(nameof(cidr), "CIDR IPv6 deve essere tra 0 e 128");

            byte[] bytes = new byte[16];

            int fullBytes = cidr / 8;
            int remainingBits = cidr % 8;

            // Full bytes
            for (int i = 0; i < fullBytes; i++) bytes[i] = 0xFF;

            // Partial byte
            if (remainingBits > 0) bytes[fullBytes] = (byte)(0xFF << (8 - remainingBits));

            return new IPAddress(bytes);
        }

        public static int MaskToCidrIPv4(IPAddress mask)
        {
            if (mask == null) throw new ArgumentNullException(nameof(mask));

            byte[] bytes = mask.GetAddressBytes();

            if (bytes.Length != 4) throw new ArgumentException("The address is not IPv4", nameof(mask));

            int cidr = 0;
            bool zeroFound = false;

            foreach (byte b in bytes)
            {
                for (int i = 7; i >= 0; i--)
                {
                    bool bitIsOne = (b & (1 << i)) != 0;

                    if (bitIsOne)
                    {
                        if (zeroFound)
                            throw new ArgumentException("Subnet mask IPv4 non contigua.", nameof(mask));

                        cidr++;
                    }
                    else
                    {
                        zeroFound = true;
                    }
                }
            }

            return cidr;
        }

        public static int MaskToCidrIPv6(IPAddress mask)
        {
            if (mask == null)
                throw new ArgumentNullException(nameof(mask));

            byte[] bytes = mask.GetAddressBytes();

            if (bytes.Length != 16)
                throw new ArgumentException("L'indirizzo non è IPv6.", nameof(mask));

            int cidr = 0;
            bool zeroFound = false;

            foreach (byte b in bytes)
            {
                for (int i = 7; i >= 0; i--)
                {
                    bool bitIsOne = (b & (1 << i)) != 0;

                    if (bitIsOne)
                    {
                        if (zeroFound)
                            throw new ArgumentException("Subnet mask IPv6 non contigua.", nameof(mask));

                        cidr++;
                    }
                    else
                    {
                        zeroFound = true;
                    }
                }
            }

            return cidr;
        }

    }
}
