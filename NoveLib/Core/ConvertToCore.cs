using System;
using System.Globalization;
using System.Runtime.CompilerServices;

namespace NoveLib.Core
{
    internal class ConvertToCore
    { }

public static class ByteSizeFormatter
    {
        private static readonly string[] Suffixes = { "B", "KB", "MB", "GB", "TB" };

        // Reciprocal multipliers (1 / 1024^n) per velocizzare divisione
        private const double RECIP_KB = 1d / 1024d;
        private const double RECIP_MB = 1d / (1024d * 1024d);
        private const double RECIP_GB = 1d / (1024d * 1024d * 1024d);
        private const double RECIP_TB = 1d / (1024d * 1024d * 1024d * 1024d);

        //[MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static string Format(long bytes, int decimalPlaces = 2)
        {
            if (bytes < 1024)
            {
                if (bytes == 1)
                    return "1 Byte";
                return bytes.ToString(CultureInfo.InvariantCulture) + " Bytes";
            }

            double value;
            int order;

            // Branch prediction–friendly ordering (big sizes first)
            if (bytes >= 1099511627776L) // 1 TB
            {
                value = bytes * RECIP_TB;
                order = 4;
            }
            else if (bytes >= 1073741824L) // 1 GB
            {
                value = bytes * RECIP_GB;
                order = 3;
            }
            else if (bytes >= 1048576L) // 1 MB
            {
                value = bytes * RECIP_MB;
                order = 2;
            }
            else // KB
            {
                value = bytes * RECIP_KB;
                order = 1;
            }

#if NET10_0_OR_GREATER
            // Alloc molto ridotta, zero overhead, super veloce
            return string.Create(
                32,
                (value, order, decimalPlaces),
                (span, state) =>
                {
                    var (v, o, dp) = state;
                    v.TryFormat(span, out int written, $"N{dp}", CultureInfo.InvariantCulture);
                    span[written++] = ' ';
                    Suffixes[o].AsSpan().CopyTo(span.Slice(written));
                }
            ).TrimEnd('\0');
#else
        // Fallback per .NET 4.8 (più veloce di string.Format)
        return value.ToString("N" + decimalPlaces, CultureInfo.InvariantCulture)
               + " " + Suffixes[order];
#endif
        }
    }
}
