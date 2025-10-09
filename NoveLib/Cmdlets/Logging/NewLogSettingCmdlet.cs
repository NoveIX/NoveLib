using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace NoveLib.cmdlet.logging
{
    [Cmdlet(VerbsCommon.New, "LogSetting")]
    public class NewLogSettingCmdletCommand : PSCmdlet
    {
        // Log Definition
        [Parameter]
        public string Name { get; set; }

        [Parameter]
        public string Path { get; set; }

        [Parameter]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        public string LogMinLevel { get; set; } = "INFO";

        // Log User
        [Parameter]
        public SwitchParameter UseUserInName { get; set; }

        [Parameter]
        public SwitchParameter UserDirInSubPath { get; set; }

        // Log Format
        [Parameter]
        [ValidateSet("None", "Date", "Datetime")]
        public string DateInLogName { get; set; } = "None";

        [Parameter]
        [ValidateSet("Time", "Datetime")]
        public string LogFormat { get; set; } = "Time";

        [Parameter]
        public SwitchParameter UseMillisecond { get; set; }

        // Console Mode
        [Parameter]
        [ValidateSet("None", "Message", "Timestamp")]
        public string ConsoleOutput { get; set; } = "None";

        // Cmdlet Logic
        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            var logSetting = CreateLogSetting();
            WriteObject(logSetting);
        }

        internal LogSetting CreateLogSetting()
        {
            // # ========================================[ Handle path ]========================================= #

            // Log Path
            string filePath = Path;
            if (string.IsNullOrWhiteSpace(filePath))
            {
                // If the script was not started from a file, use the current folder.
                string basePath = !string.IsNullOrWhiteSpace(MyInvocation.MyCommand.Definition)
                    ? System.IO.Path.GetDirectoryName(MyInvocation.MyCommand.Definition)
                    : SessionState.Path.CurrentFileSystemLocation.Path;

                filePath = System.IO.Path.Combine(basePath, "logs");
            }
            else if (!System.IO.Path.IsPathRooted(filePath))
            {
                // Converts to absolute path if relative
                filePath = System.IO.Path.GetFullPath(System.IO.Path.Combine(
                    SessionState.Path.CurrentFileSystemLocation.Path,
                    Path));
            }

            // # ======================================[ Handle Filename ]======================================= #

            // Defines a log file name if missing
            string fileName = Name;
            if (string.IsNullOrWhiteSpace(fileName))
            {
                fileName = MyInvocation.MyCommand.Definition != null
                    ? System.IO.Path.GetFileNameWithoutExtension(MyInvocation.MyCommand.Name)
                    : "log";
            }
            else
            { fileName = System.IO.Path.GetFileNameWithoutExtension(fileName); }

            // # =====================================[ Construct log path ]===================================== #

            // Add username in file name
            if (UseUserInName.IsPresent) { fileName += $"_{Environment.UserName}"; }

            // Add date in file name
            if (DateInLogName == "Date") { fileName += $"_{DateTime.Now:yyyy-MM-dd}"; }
            else if (DateInLogName == "Datetime") { fileName += $"_{DateTime.Now:yyyy-MM-dd_HH-mm-ss}"; }

            // add extension
            fileName += ".log";

            // construct full path
            filePath = UserDirInSubPath.IsPresent
                ? System.IO.Path.Combine(filePath, Environment.UserName, fileName)
                : System.IO.Path.Combine(filePath, fileName);

            // # =================================[ Return NoveLib.LogSetting ]================================== #

            // Return LogSetting
            return new LogSetting(filePath, logMinLevel, LogFormat, ConsoleOutput, UseMillisecond);
        }
    }
}