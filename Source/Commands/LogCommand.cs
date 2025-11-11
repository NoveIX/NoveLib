using NoveLib.Source.Common.Enums;
using NoveLib.Source.Common.Helpers;
using NoveLib.Source.Core;
using NoveLib.Source.Models;
using System;
using System.IO;
using System.Management.Automation;

namespace NoveLib.Source.Commands
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
            // Handle log path
            string logPath = FSHelper.ResolvePathPS(Path, "logs", this);
            string logName = FSHelper.ResolveFilePS(Name, "log", this);

            // Get other parameters
            LogLevel logLevel = LogLevel;
            LogFormat logFormat = LogFormat;
            LogDate logDate = LogDate;
            bool consolePrint = ConsolePrint.IsPresent;
            bool setDefault = SetDefault.IsPresent;

            // Create LogSetting object
            LogSetting logSetting = LogManager.CreateLogSetting(logName, logPath, logLevel, logFormat, logDate, consolePrint, setDefault);

            // Set as default if specified
            if (setDefault) Global.DefaultLogSetting = logSetting;

            // Ouptput LogSetting object
            WriteObject(logSetting);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogTrace")]
    public class WriteLogTraceCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Trace, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogDebug")]
    public class WriteLogDebugCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Debug, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogInfo")]
    public class WriteLogInfoCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Info, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogWarn")]
    public class WriteLogWarnCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;
            LogManager.WriteLog(LogLevel.Warn, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogError")]
    public class WriteLogErrorCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Error, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogFatal")]
    public class WriteLogFatalCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Fatal, Message, logSetting, Print, func);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogDone")]
    public class WriteLogDoneCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        [Parameter(Position = 1)]
        public SwitchParameter Print { get; set; }

        [Parameter(Position = 2)]
        public LogSetting LogSetting { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            LogSetting logSetting = LogSetting;
            logSetting ??= Global.DefaultLogSetting;
            if (logSetting == null)
            {
                string sysMsg = "DefaultLogSetting is not set. Please provide a LogSetting object or set a default one using New-LogSetting -SetDefault.";
                throw new InvalidOperationException(sysMsg);
            }

            string psFile = null;
            int psLine = 0;
            string func = null;

            if (logSetting.LogFormat == LogFormat.Verbose)
            {
                psFile = Path.GetFileName(MyInvocation.ScriptName);
                psLine = MyInvocation.ScriptLineNumber;
            }
            if (logSetting.LogFormat is LogFormat.Detailed or LogFormat.ISO8601 or LogFormat.Verbose) func = MyInvocation.MyCommand.Name;

            LogManager.WriteLog(LogLevel.Done, Message, logSetting, Print, func);
        }
    }
}