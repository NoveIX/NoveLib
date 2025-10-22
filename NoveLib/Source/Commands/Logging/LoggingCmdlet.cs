using NoveLib.Helpers;
using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace NoveLib.Cmdlets.logging
{
    // Cmdlet to create a new LogSetting object
    [Cmdlet(VerbsCommon.New, "LogSetting")]
    public class NewLogSettingCommand : PSCmdlet
    {
        // Log Definition
        [Parameter]
        public string Name { get; set; }

        [Parameter]
        public string Path { get; set; }

        [Parameter]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        public string MinLevel { get; set; } = "INFO";

        // Log Format
        [Parameter]
        [ValidateSet("Time", "Datetime")]
        public string Format { get; set; } = "Time";

        [Parameter]
        [ValidateSet("None", "Date", "Datetime")]
        public string DateInName { get; set; } = "None";

        // Console Mode
        [Parameter]
        [ValidateSet("None", "Message", "Timestamp")]
        public string ConsoleMode { get; set; } = "None";

        [Parameter]
        public SwitchParameter Millisecond { get; set; }

        // Log User
        [Parameter]
        public SwitchParameter UsernameInLogName { get; set; }

        [Parameter]
        public SwitchParameter UsernameInSubDirPath { get; set; }

        // Default Log Setting
        [Parameter]
        public SwitchParameter SetDefault { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            // Handle log path
            string logPath = Path;
            string basePath;

            if (string.IsNullOrWhiteSpace(logPath))
            {
                // Take base path from script location or current location
                basePath = !string.IsNullOrEmpty(MyInvocation.PSCommandPath)
                    ? System.IO.Path.GetDirectoryName(MyInvocation.PSCommandPath)
                    : SessionState.Path.CurrentFileSystemLocation.Path;

                // Construct default log path
                logPath = System.IO.Path.Combine(basePath, "logs");
            }
            else if (!System.IO.Path.IsPathRooted(logPath))
            {
                // Convert to absolute path if relative
                logPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(
                    SessionState.Path.CurrentFileSystemLocation.Path, logPath));
            }

            // Handle log name
            string logName = Name;

            if (string.IsNullOrWhiteSpace(logName))
            {
                // Get log name from script name or default
                logName = !string.IsNullOrWhiteSpace(MyInvocation.PSCommandPath)
                    ? System.IO.Path.GetFileNameWithoutExtension(MyInvocation.PSCommandPath)
                    : "log"; // Default log name
            }
            else
            {
                // Remove extension if provided
                logName = System.IO.Path.GetFileNameWithoutExtension(logName);
            }

            // Sanitize log name
            foreach (char c in System.IO.Path.GetInvalidFileNameChars()) logName = logName.Replace(c, '_');

            // Convert string e and switch in enum
            LogLevel logMinLevel = (LogLevel)Enum.Parse(typeof(LogLevel), MinLevel, true);
            LogFormat logFormat = (LogFormat)Enum.Parse(typeof(LogFormat), Format, true);
            LogDate logDateName = (LogDate)Enum.Parse(typeof(LogDate), DateInName, true);
            LogConsole consoleMode = (LogConsole)Enum.Parse(typeof(LogConsole), ConsoleMode, true);
            bool millisecond = Millisecond.IsPresent;
            bool userLogName = UsernameInLogName.IsPresent;
            bool userLogDir = UsernameInSubDirPath.IsPresent;

            // Create LogSetting object
            LogSetting logSetting = Logger.CreateLogSetting(logName, logPath, logMinLevel, logFormat, millisecond, logDateName, consoleMode, userLogName, userLogDir);

            // Set as default log setting if specified
            if (SetDefault.IsPresent) Global.DefaultLogSetting = logSetting;

            // Output the LogSetting object
            WriteObject(logSetting);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogTrace")]
    public class WriteLogTraceCommand : PSCmdlet
    {
        // Log Message
        [Parameter(Mandatory = true, Position = 0)]
        public string Message { get; set; }

        // Print to console
        [Parameter] public SwitchParameter Print { get; set; }
        [Parameter] public SwitchParameter PrintTime { get; set; }

        // Log Setting
        [Parameter] public LogSetting LogSetting { get; set; }
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

            if (Print.IsPresent && PrintTime.IsPresent) Print = false;

            Logger.WriteLog(LogLevel.Trace, Message, logSetting, Print, PrintTime);
        }
    }
}
