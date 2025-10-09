using NoveLib.Helpers;

namespace NoveLib.Models
{

    public class LogSetting
    {
        public string LogPath { get; set; }
        public LogLevel LogMinLevel { get; set; }
        public string LogFormat { get; set; }
        public string ConsoleOutput { get; set; }
        public bool Millisecond { get; set; }

        public LogSetting(string logPath, LogLevel logMinLevel, string logFormat, string consoleOutput, bool millisecond)
        {
            LogPath = logPath;
            LogMinLevel = logMinLevel;
            LogFormat = logFormat;
            ConsoleOutput = consoleOutput;
            Millisecond = millisecond;
        }
    }
}