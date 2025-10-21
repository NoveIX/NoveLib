using NoveLib.Helpers;

namespace NoveLib.Models
{
    public class LogSetting(string logPath, LogLevel logMinLevel, LogFormat logFormat, LogConsole consoleOutput, bool millisecond)
    {
        public string LogPath { get; set; } = logPath;
        public LogLevel LogMinLevel { get; set; } = logMinLevel;
        public LogFormat LogFormat { get; set; } = logFormat;
        public LogConsole ConsoleOutput { get; set; } = consoleOutput;
        public bool Millisecond { get; set; } = millisecond;
    }
}