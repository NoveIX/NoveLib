using NoveLib.Source.Common.Enums;
using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Core;
using NoveLib.Source.Models;
using System;
using System.IO;
using System.Management.Automation;

namespace NoveLib.Source.Commands
{
    /// <summary>
    /// Creates a new log setting configuration with the specified parameters and outputs the resulting LogSetting
    /// object.
    /// </summary>
    /// <remarks>This cmdlet allows you to define log settings such as name, path, log level, format, and date
    /// style, and optionally set the configuration as the default for subsequent operations. If the SetDefault switch
    /// is specified, the created log setting will be set as the global default. The cmdlet outputs the created
    /// LogSetting object, which can be used for further configuration or logging operations.</remarks>
    [Cmdlet(VerbsCommon.New, "LogSetting")]
    public class NewLogSettingCommand : PSCmdlet
    {
        /// <summary>
        /// Gets or sets the name associated with the parameter.
        /// </summary>
        [Parameter(Position = 0)]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the file system path to be used by the command.
        /// </summary>
        /// <remarks>The path can be absolute or relative. Ensure that the specified path exists and is
        /// accessible to avoid errors during command execution.</remarks>
        [Parameter(Position = 1)]
        public string Path { get; set; }

        /// <summary>
        /// Gets or sets the minimum level of log messages that will be recorded.
        /// </summary>
        /// <remarks>Valid values are Trace, Debug, Info, Warn, Error, Fatal, and Done. Messages below the
        /// specified level will be ignored. The default value is Info.</remarks>
        [Parameter(Position = 2)]
        [ValidateSet("Trace", "Debug", "Info", "Warn", "Error", "Fatal", "Done")]
        public LogLevel LogLevel { get; set; } = LogLevel.Info;

        /// <summary>
        /// Gets or sets the format used for log output.
        /// </summary>
        /// <remarks>Supported formats include Default, Simple, Detailed, Compact, ISO8601, and Verbose.
        /// The selected format determines the structure and level of detail included in each log entry.</remarks>
        [Parameter(Position = 3)]
        [ValidateSet("Default", "Simple", "Detailed", "Compact", "ISO8601", "Verbose")]
        public LogFormat LogFormat { get; set; } = LogFormat.Default;

        /// <summary>
        /// Gets or sets the format to use for logging date and time information.
        /// </summary>
        /// <remarks>Specify the desired date or date-time format for log entries. Valid options are
        /// "None", "DateCompact", "DateHyphen", "DateTimeCompact", and "DateTimeHyphen". The selected format determines
        /// how date and time values appear in the log output.</remarks>
        [Parameter(Position = 4)]
        [ValidateSet("None", "DateCompact", "DateHyphen", "DateTimeCompact", "DateTimeHyphen")]
        public LogDate LogDate { get; set; } = LogDate.None;

        /// <summary>
        /// Gets or sets a value indicating whether the output should be printed to the console.
        /// </summary>
        [Parameter(Position = 5)]
        public SwitchParameter ConsolePrint { get; set; }

        /// <summary>
        /// Gets or sets a value that indicates whether the default configuration should be applied.
        /// </summary>
        [Parameter(Position = 6)]
        public SwitchParameter SetDefault { get; set; }

        /// <summary>
        /// Processes the current PowerShell record to create and output a new log setting based on the provided
        /// parameters.
        /// </summary>
        /// <remarks>If the SetDefault parameter is specified, the created log setting is also set as the
        /// global default. The method resolves the log file path and name using the specified Path and Name parameters,
        /// and applies additional configuration such as log level, format, date, and console output options. The
        /// resulting LogSetting object is written to the output stream for further use in the PowerShell
        /// pipeline.</remarks>
        protected override void ProcessRecord()
        {
            // Handle log path and name
            string logPath = FileSystemHelper.ResolvePathPS(Path, "logs", this);
            string logName = FileSystemHelper.ResolveFilePS(Name, "log", this);

            // Get other parameters
            LogLevel logLevel = LogLevel;
            LogFormat logFormat = LogFormat;
            LogDate logDate = LogDate;
            bool consolePrint = ConsolePrint.IsPresent;
            bool setDefault = SetDefault.IsPresent;

            // Create LogSetting object
            LogSetting logSetting = LogCore.CreateLogSetting(logName, logPath, logLevel, logFormat, logDate, consolePrint, setDefault);

            // Set as default if specified
            if (setDefault) Global.DefaultLogSetting = logSetting;

            // Ouptput LogSetting object
            WriteObject(logSetting);
        }
    }

    // ================================================================

    /// <summary>
    /// Provides a base class for PowerShell cmdlets that write log entries with configurable log levels, message
    /// content, and output settings.
    /// </summary>
    /// <remarks>Derive from this class to implement custom logging cmdlets that support flexible log
    /// formatting and output options. The logging behavior can be tailored using the LogSetting property, which
    /// determines the format and details included in each log entry. If no log setting is specified, a global default
    /// is used if available. This class integrates with the PowerShell pipeline and supports printing log messages to
    /// the console as needed.</remarks>
    public abstract class WriteLogBase : PSCmdlet
    {
        /// <summary>
        /// Each derived cmdlet specifies its own log level.
        /// </summary>
        protected abstract LogLevel Level { get; }

        /// <summary>
        /// Gets or sets the message text to be processed or displayed.
        /// </summary>
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        /// <summary>
        /// Gets or sets a value that indicates whether the output should be printed to the console.
        /// </summary>
        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        /// <summary>
        /// Gets or sets the configuration settings for logging behavior.
        /// </summary>
        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        /// <summary>
        /// Processes the current record by writing a log entry using the specified log settings and message parameters.
        /// </summary>
        /// <remarks>The log entry format and included details depend on the LogFormat specified in the
        /// log settings. For verbose and detailed formats, additional context such as script name, line number, and
        /// command name may be included in the log output.</remarks>
        /// <exception cref="InvalidOperationException">Thrown if no log setting is provided and no default log setting is configured. Ensure that either the
        /// LogSetting property is set or a default log setting is established before invoking this method.</exception>
        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            LogSetting logSetting = LogSetting ?? Global.DefaultLogSetting
                ?? throw new InvalidOperationException(
                    "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault."
                    );

            string file = null;
            int line = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                file = Path.GetFileName(MyInvocation.ScriptName);
                line = MyInvocation.ScriptLineNumber;
            }

            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose)
                func = MyInvocation.MyCommand.Name;

            LogCore.WriteLog(Level, Message, logSetting, Print, func, file, line);
        }
    }

    // ================================================================

    /// <summary>
    /// Provides a cmdlet that writes log entries at the Trace level.
    /// </summary>
    /// <remarks>Use this cmdlet to record detailed diagnostic information for troubleshooting and low-level
    /// tracing. The Trace log level is typically used for verbose output and may generate a large volume of log data.
    /// This cmdlet inherits common logging functionality from WriteLogBase.</remarks>
    [Cmdlet(VerbsCommunications.Write, "LogTrace")]
    public class WriteLogTraceCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Trace;
    }

    // ================================================================

    /// <summary>
    /// Provides a cmdlet that writes log messages at the Debug level.
    /// </summary>
    /// <remarks>Use this cmdlet to output diagnostic information intended for debugging purposes. Messages
    /// written with this cmdlet are typically only visible when the logging system is configured to include Debug-level
    /// output.</remarks>
    [Cmdlet(VerbsCommunications.Write, "LogDebug")]
    public class WriteLogDebugCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Debug;
    }

    // ================================================================

    /// <summary>
    /// Provides a cmdlet that writes informational log messages with the Info log level.
    /// </summary>
    /// <remarks>Use this cmdlet to log messages that convey general information about application execution.
    /// The Info level is typically used for messages that highlight the progress of the application at a coarse-grained
    /// level. This cmdlet inherits common logging functionality from WriteLogBase.</remarks>
    [Cmdlet(VerbsCommunications.Write, "LogInfo")]
    public class WriteLogInfoCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Info;
    }

    // ================================================================

    /// <summary>
    /// Represents a cmdlet that writes warning-level log messages to the logging system.
    /// </summary>
    [Cmdlet(VerbsCommunications.Write, "LogWarn")]
    public class WriteLogWarnCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Warn;
    }

    // ================================================================

    /// <summary>
    /// Represents the Write-LogError cmdlet, which writes an error-level entry to the log.
    /// </summary>
    /// <remarks>Use this cmdlet to record error messages in the log with the Error severity level. This is
    /// typically used to capture failures or issues that require attention. Inherits common logging parameters and
    /// behavior from WriteLogBase.</remarks>
    [Cmdlet(VerbsCommunications.Write, "LogError")]
    public class WriteLogErrorCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Error;
    }

    // ================================================================

    /// <summary>
    /// Provides a cmdlet that writes log entries with the Fatal severity level.
    /// </summary>
    /// <remarks>Use this cmdlet to log critical errors that require immediate attention. Entries written with
    /// the Fatal level indicate unrecoverable failures or conditions that will cause the application to
    /// terminate.</remarks>
    [Cmdlet(VerbsCommunications.Write, "LogFatal")]
    public class WriteLogFatalCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Fatal;
    }

    // ================================================================

    /// <summary>
    /// Gets the log level that indicates a completed operation for this logger instance.
    /// </summary>
    [Cmdlet(VerbsCommunications.Write, "LogDone")]
    public class WriteLogDoneCommand : WriteLogBase
    {
        /// <summary>
        /// Gets the log level used by this logger instance.
        /// </summary>
        protected override LogLevel Level => LogLevel.Done;
    }
}