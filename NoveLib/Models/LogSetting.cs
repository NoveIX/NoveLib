using NoveLib.Helpers;

namespace NoveLib.Models
{

    public class LogSetting
    {
        public string LogPath { get; set; }
        public LogLevel LogMinLevel { get; set; }
        public string LogFormat { get; set; }
        public string ConsoleOutput { get; set; }
        public bool UseMillisecond { get; set; }

        public LogSetting(string logPath, LogLevel logMinLevel, string logFormat, string consoleOutput, bool useMillisecond)
        {
            LogPath = logPath;
            LogMinLevel = logMinLevel;
            LogFormat = logFormat;
            ConsoleOutput = consoleOutput;
            UseMillisecond = useMillisecond;
        }
    }
}