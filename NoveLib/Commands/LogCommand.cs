using NoveLib.Common.Enums;
using NoveLib.Common.Helpers;
using NoveLib.Core;
using NoveLib.Models;
using System;
using System.IO;
using System.Management.Automation;

namespace NoveLib.Commands
{
    [Cmdlet(VerbsCommon.New, "LogSetting")]
    public class NewLogSettingCommand : PSCmdlet
    {
        [Parameter(Position = 0)]
        public string Name { get; set; }

        [Parameter(Position = 1)]
        public string Path { get; set; }

        [Parameter(Position = 2)]
        [ValidateSet("Trace", "Debug", "Info", "Warn", "Error", "Fatal", "Done")]
        public LogLevel LogLevel { get; set; } = LogLevel.Info;

        [Parameter(Position = 3)]
        [ValidateSet("Default", "Simple", "Detailed", "Compact", "ISO8601", "Verbose")]
        public LogFormat LogFormat { get; set; } = LogFormat.Default;

        [Parameter(Position = 4)]
        [ValidateSet("None", "DateCompact", "DateHyphen", "DateTimeCompact", "DateTimeHyphen")]
        public LogDate LogDate { get; set; } = LogDate.None;

        [Parameter(Position = 5)]
        public SwitchParameter ConsolePrint { get; set; }

        [Parameter(Position = 6)]
        public SwitchParameter SetDefault { get; set; }

        protected override void ProcessRecord()
        {
            // Handle log path and name
            string logPath = FileSystemHelper.ResolvePathPS(Path, "logs", this);
            string logName = FileSystemHelper.ResolveNamePS(Name, "log", this);

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

    [Cmdlet(VerbsCommon.Set, "DefaultLogSetting")]
    public class SetDefaultLogSettingCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public LogSetting LogSetting { get; set; }
        protected override void ProcessRecord()
        {
            // Set the default global log Setting
            Global.DefaultLogSetting = LogSetting;

            // Optional informational message -Verbose
            WriteVerbose("Default log setting has been updated.");
        }
    }

    // ================================================================

    public abstract class WriteLogBase : PSCmdlet
    {
        protected abstract LogLevel Level { get; }

        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

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

    [Cmdlet(VerbsCommunications.Write, "LogTrace")]
    public class WriteLogTraceCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Trace;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogDebug")]
    public class WriteLogDebugCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Debug;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogInfo")]
    public class WriteLogInfoCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Info;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogWarn")]
    public class WriteLogWarnCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Warn;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogError")]
    public class WriteLogErrorCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Error;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogFatal")]
    public class WriteLogFatalCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Fatal;
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogDone")]
    public class WriteLogDoneCommand : WriteLogBase
    {
        protected override LogLevel Level => LogLevel.Done;
    }
}