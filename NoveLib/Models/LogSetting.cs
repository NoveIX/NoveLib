using NoveLib.Common.Enums;

namespace NoveLib.Models
{
    public class LogSetting(string logFile, LogLevel logLevel, LogFormat logFormat, bool consolePrint, bool setDefault)
    {
        public string LogFile { get; set; } = logFile;
        public LogLevel LogLevel { get; set; } = logLevel;
        public LogFormat LogFormat { get; set; } = logFormat;
        public bool ConsolePrint { get; set; } = consolePrint;
        public bool Default { get; set; } = setDefault;
    }
}