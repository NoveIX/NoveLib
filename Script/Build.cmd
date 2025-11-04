@echo off
setlocal

REM Move the working context to the project folder
cd /d "%~dp0\.."

REM Check if dotnet is available
where dotnet >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR]: The 'dotnet' command was not found. Make sure that the .NET SDK is installed and in your PATH.
    exit /b 1
)

REM Build project
echo [INFO]: Compiling the project in progress...
dotnet build

pause
endlocal
