using NoveLib.Source.Common.Enums;
using NoveLib.Source.Core;
using NoveLib.Source.Models;
using System.Linq;
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
        [ValidateSet(
            "Trace", // Maximum details
            "Debug", // Debug info
            "Info",  // General information
            "Warn",  // Warnings
            "Error", // Errors
            "Fatal", // Critical errors
            "Done"   // Successfully completed
        )]
        public LogLevel LogLevel { get; set; } = LogLevel.Info;

        [Parameter(Position = 3)]
        [ValidateSet(
            "Default",  // [yyyy-MM-dd HH:mm:ss] [Level]: Message
            "Simple",   // [Level]: Message
            "Detailed", // [yyyy-MM-dd HH:mm:ss.fff] [Level] [SourceContext]: Message
            "Compact",  // HH:mm:ss Level: Message
            "ISO8601"   // [yyyy-MM-ddTHH:mm:ss.fffZ] [Level] [SourceContext]: Message (UTC)
        )]
        public LogFormat LogFormat { get; set; } = LogFormat.Default;

        [Parameter(Position = 4)]
        [ValidateSet(
            "None",             // logname.log
            "DateCompact",      // logname_20251024.log
            "DateHyphen",       // logname_2025-10-24.log
            "DateTimeCompact",  // logname_20251024_143000.log
            "DateTimeHyphen"    // logname_2025-10-24_14-30-00.log
            )]
        public LogDate LogDate { get; set; } = LogDate.None;

        [Parameter(Position = 5)]
        public SwitchParameter ConsolePrint { get; set; }

        [Parameter(Position = 6)]
        public SwitchParameter SetDefault { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            //Handle log path
            string logPath = Path;
            string basePath;

            if (string.IsNullOrWhiteSpace(logPath))
            {
                //Take base path from script location or current location
                basePath = !string.IsNullOrEmpty(MyInvocation.ScriptName)
                    ? System.IO.Path.GetDirectoryName(MyInvocation.ScriptName)
                    :SessionState.Path.CurrentFileSystemLocation.Path;

                // Constuct default log path
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
                logName = !string.IsNullOrWhiteSpace(MyInvocation.ScriptName)
                    ? System.IO.Path.GetFileNameWithoutExtension(MyInvocation.ScriptName)
                    : "log"; // Default log name
            }
            else
            {
                // Remove extension if provided
                logName = System.IO.Path.GetFileNameWithoutExtension(logName);
            }

            // Sanitize log name
            logName = string.Concat(logName.Select(ch => System.IO.Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));

            // Get other parameters
            LogLevel logLevel = LogLevel;
            LogFormat logFormat = LogFormat;
            LogDate logDate = LogDate;
            bool consolePrint = ConsolePrint.IsPresent;

            // Create LogSetting object
            LogSetting logSetting = LogManager.CreateLogSetting(logName, logPath, logLevel, logFormat, logDate, consolePrint);

            // Set as default if specified
            if (SetDefault.IsPresent) Global.DefaultLogSetting = logSetting;

            // Ouptput LogSetting object
            WriteObject(logSetting);
        }
    }

    // ================================================================

    [Cmdlet(VerbsCommunications.Write, "LogTrace")]
    public class  WriteLogCommand : PSCmdlet
    {
        
    }
}