@echo off
REM ================================================================================
REM SCRIPT NAME : ScriptName.cmd
REM
REM SYNOPSIS
REM     Brief one-line summary of what the script does.
REM
REM DESCRIPTION
REM     Detailed description of the script. Explain its purpose, behavior,
REM     and any important details users should know.
REM
REM PARAMETERS
REM     Parameter1 : Description of the parameter, what it does, valid values,
REM                  and any default behavior.
REM     Parameter2 : Description of the second parameter.
REM     Parameter3 : Description of the third parameter.
REM
REM EXAMPLES
REM     Example 1:
REM         ScriptName.cmd Value1
REM
REM     Example 2:
REM         ScriptName.cmd Value2 /verbose
REM
REM     Example 3:
REM         ScriptName.cmd
REM
REM INPUTS
REM     Type(s) of input the script accepts, if any.
REM     Use 'None' if not applicable.
REM     Example: [String], [Number], [Switch]
REM
REM OUTPUTS
REM     Type(s) of output the script returns, if any.
REM     Use 'None' if not applicable.
REM     Example: [Boolean], [String], [File]
REM
REM NOTES
REM     Additional information such as author, date, version, or special considerations.
REM     Author       : Firstname Lastname
REM     Company      : Unknown
REM     Created      : YYYY/MM/DD
REM     Last Update  : YYYY/MM/DD
REM     Version      : 1.0
REM     Purpose      : Template
REM     Requirements : Windows CMD
REM     Compatibility: Windows (adjust if needed)
REM     License      : All rights reserved
REM     Changelog    : Initial release
REM
REM LINKS
REM     CMD documentation     : https://learn.microsoft.com/windows-server/administration/windows-commands/cmd
REM     Batch scripting guide : https://ss64.com/nt/
REM     GitHub repository     : https://github.com/your-repo
REM ================================================================================

:: --- Handle Help Request ---
IF "%~1"=="/?" GOTO :help
IF "%~1"=="-h" GOTO :help
IF "%~1"=="--help" GOTO :help

:: --- Your main script logic here ---
ECHO Running main script...
GOTO :eof

:help
ECHO ================================================================
ECHO SCRIPT NAME : ScriptName.cmd
ECHO.
ECHO SYNOPSIS
ECHO     Brief one-line summary of what the script does.
ECHO.
ECHO DESCRIPTION
ECHO     Detailed description of the script. Explain its purpose,
ECHO     behavior, and any important details users should know.
ECHO.
ECHO PARAMETERS
ECHO     Parameter1 : Description of the parameter, valid values, defaults
ECHO     Parameter2 : Description of the second parameter
ECHO     Parameter3 : Description of the third parameter
ECHO.
ECHO EXAMPLES
ECHO     Example 1: ScriptName.cmd Value1
ECHO     Example 2: ScriptName.cmd Value2 /verbose
ECHO     Example 3: ScriptName.cmd
ECHO.
ECHO INPUTS
ECHO     [String], [Number], [Switch] or None
ECHO.
ECHO OUTPUTS
ECHO     [Boolean], [String], [File] or None
ECHO.
ECHO NOTES
ECHO     Author       : Firstname Lastname
ECHO     Company      : Unknown
ECHO     Created      : YYYY/MM/DD
ECHO     Last Update  : YYYY/MM/DD
ECHO     Version      : 1.0
ECHO     Purpose      : Template
ECHO     Requirements : Windows CMD
ECHO     Compatibility: Windows
ECHO     License      : All rights reserved
ECHO     Changelog    : Initial release
ECHO.
ECHO LINKS
ECHO     CMD Docs     : https://learn.microsoft.com/windows-server/administration/windows-commands/cmd
ECHO     Batch Guide  : https://ss64.com/nt/
ECHO     GitHub Repo  : https://github.com/your-repo
ECHO ================================================================
GOTO :eof