using NoveLib.Source.Common.Enums;

namespace NoveLib.Source.Models
{
    public class LogSetting(string logFile, LogLevel logLevel, LogFormat logFormat, bool consolePrint)
    {
        public string LogFile { get; set; } = logFile;
        public LogLevel LogLevel { get; set; } = logLevel;
        public LogFormat LogFormat { get; set; } = logFormat;
        public bool ConsolePrint { get; set; } = consolePrint;
    }
}