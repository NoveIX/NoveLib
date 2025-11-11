using NoveLib.Source.Common.Enums;

namespace NoveLib.Source.Models
{
    /// <summary>
    /// Represents the settings for logging, including file path, log level, format, and console output option.
    /// </summary>
    /// <remarks>
    /// Initializes a new instance of the <see cref="LogSetting"/> class with specified log file, log level, log format, and console print option.
    /// </remarks>
    /// <param name="logFile">The path to the log file.</param>
    /// <param name="logLevel">The level min of logging.</param>
    /// <param name="logFormat">The format of the log entries.</param>
    /// <param name="consolePrint">Indicates whether to print logs to the console.</param>
    public class LogSetting(string logFile, LogLevel logLevel, LogFormat logFormat, bool consolePrint, bool setDefault)
    {
        /// <summary>
        /// Gets or sets the path to the log file.
        /// </summary>
        public string LogFile { get; set; } = logFile;
        /// <summary>
        /// Gets or sets the level min of logging.
        /// </summary>
        public LogLevel LogLevel { get; set; } = logLevel;
        /// <summary>
        /// Gets or sets the format of the log entries.
        /// </summary>
        public LogFormat LogFormat { get; set; } = logFormat;
        /// <summary>
        /// Indicates whether to print logs to the console.
        /// </summary>
        public bool ConsolePrint { get; set; } = consolePrint;

        public bool Default {  get; set; } = setDefault;
    }
}