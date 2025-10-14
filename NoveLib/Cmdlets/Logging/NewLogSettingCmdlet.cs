using NoveLib.Helpers;
using NoveLib.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
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

        // Cmdlet Logic
        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            string logPath = Path;

            // === Determina basePath ===
            string basePath;

            // Se lo script è eseguito da file .ps1, usa la sua directory
            if (!string.IsNullOrWhiteSpace(MyInvocation.MyCommand.Definition) &&
                File.Exists(MyInvocation.MyCommand.Definition))
            {
                basePath = System.IO.Path.GetDirectoryName(MyInvocation.MyCommand.Definition)!;
            }
            else
            {
                // Altrimenti usa la directory corrente di PowerShell ($PWD)
                basePath = SessionState.Path.CurrentFileSystemLocation.Path;
            }

            // === Costruisci logPath ===
            if (string.IsNullOrWhiteSpace(logPath))
            {
                // Se non è stato fornito alcun percorso, crea ./logs nella directory base
                logPath = System.IO.Path.Combine(basePath, "logs");
            }
            else if (!System.IO.Path.IsPathRooted(logPath))
            {
                // Se il percorso è relativo, convertilo in assoluto rispetto alla directory corrente
                logPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(
                    SessionState.Path.CurrentFileSystemLocation.Path,
                    logPath));
            }

            // Convert string e and switch in enum
            LogLevel logMinLevel = (LogLevel)Enum.Parse(typeof(LogLevel), MinLevel, true);
            LogFormat logFormat = (LogFormat)Enum.Parse(typeof(LogFormat), Format, true);
            LogFormat logDateName = (LogFormat)Enum.Parse(typeof(LogDate), DateInName, true);
            LogConsole consoleMode = (LogConsole)Enum.Parse(typeof(LogConsole), ConsoleMode, true);
            bool millisecond = Millisecond.IsPresent;
            bool userLogName = UsernameInLogName.IsPresent;
            bool userLogDir = UsernameInSubDirPath.IsPresent;

            LogSetting logSetting = Logger.CreateLogSetting2(Name, logPath, logMinLevel, logFormat, millisecond, logDateName, consoleMode, userLogName, userLogDir);
            WriteObject(logSetting);

        }

        /*         internal LogSetting CreateLogSetting()
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
                    return new LogSetting(filePath, LogMinLevel, LogFormat, ConsoleOutput, UseMillisecond);
                }
                 */
    }
}