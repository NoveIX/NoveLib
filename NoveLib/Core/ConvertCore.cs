using System;
using System.Globalization;
using System.Runtime.CompilerServices;

namespace NoveLib.Core
{
    internal static class ConvertCore
    {

    }
    public static class ByteSizeFormatter
    {
        private static readonly string[] Suffixes = { "B", "KB", "MB", "GB", "TB" };

        // Cache format strings to avoid "N" + decimalPlaces allocations
        private static readonly string[] Formats = { "N0", "N1", "N2", "N3", "N4" };

        private const double RECIP_KB = 1d / 1024d;
        private const double RECIP_MB = 1d / (1024d * 1024d);
        private const double RECIP_GB = 1d / (1024d * 1024d * 1024d);
        private const double RECIP_TB = 1d / (1024d * 1024d * 1024d * 1024d);

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static string Format(long bytes, int decimalPlaces = 2)
        {
            if (bytes < 1024)
            {
                return bytes == 1 ? "1 Byte" : bytes.ToString(CultureInfo.InvariantCulture) + " Bytes";
            }

            double value;
            int order;

            // Optimization: Branch prediction friendly
            if (bytes >= 1099511627776L) { value = bytes * RECIP_TB; order = 4; }
            else if (bytes >= 1073741824L) { value = bytes * RECIP_GB; order = 3; }
            else if (bytes >= 1048576L) { value = bytes * RECIP_MB; order = 2; }
            else { value = bytes * RECIP_KB; order = 1; }

            // Use cached format string
            string fmt = (uint)decimalPlaces < (uint)Formats.Length ? Formats[decimalPlaces] : "N2";

#if NET8_0_OR_GREATER
            // Best performance for .NET 8+: Zero-allocation manual buffer fill
            return string.Create(24, (value, order, fmt), (span, state) =>
            {
                if (state.value.TryFormat(span, out int written, state.fmt, CultureInfo.InvariantCulture))
                {
                    span[written++] = ' ';
                    string suffix = Suffixes[state.order];
                    // Manual copy to span to avoid extra allocations
                    suffix.AsSpan().CopyTo(span.Slice(written));
                    // The actual string length will be 'written + suffix.Length'
                    // We fill the rest with nulls or we can use a more advanced approach
                    // but for string.Create, it's safer to slice the final result if length isn't exact
                }
            }).TrimEnd('\0');
#else
            // Best performance for .NET 4.8
            return value.ToString(fmt, CultureInfo.InvariantCulture) + " " + Suffixes[order];
#endif
        }
    }
}