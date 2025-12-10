using NoveLib.Common.Enums;

namespace NoveLib.Global.Config
{
    internal static class CipherConfig
    {
        // Cipher Configuration General Settings
        internal static string Keylength = "256"; // Supported sizes: 128, 192, 256
    }
    internal static class ConvertConfig
    {
        // Convertion Configuration General Settings
        internal static int DecimalPlace = 2;
    }

    internal static class LogConfig
    {
        // Log Configuration General Settings
        internal static LogLevel LogLevel = LogLevel.Info;
        internal static LogFormat LogFormat = LogFormat.Default;
        internal static LogDate LogDate = LogDate.None;
    }
}