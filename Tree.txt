NoveLib/
├───src/
│   ├───Cmdlets/
│   │   ├───Logging/
│   │   │       WriteLogCmdlet.cs
│   │   │       WriteLogInfoCmdlet.cs
│   │   │       WriteLogErrorCmdlet.cs
│   │   │       NewLogSettingCmdlet.cs
│   │   │       SetDefaultLogSettingCmdlet.cs
│   │   ├───FileSystem/
│   │   │       CopyFileCmdlet.cs
│   │   ├───Math/
│   │   │       ConvertByteToSizeCmdlet.cs
│   │   │       ConvertByteToSizeStringCmdlet.cs
│   │   ├───Network/
│   │   │       ConvertCIDRToMaskCmdlet.cs
│   │   │       ConvertMaskToCIDRCmdlet.cs
│   │   │       ConvertPathToUNCCmdlet.cs
│   │   │       ConvertStringToMacAddressCmdlet.cs
│   │   ├───Security/
│   │   │       InvokeCipherEncryptCmdlet.cs
│   │   │       InvokeCipherDecryptCmdlet.cs
│   │   │       InvokeDecryptSecureStringCmdlet.cs
│   │   │       NewCipherKeyCmdlet.cs
│   │   ├───System/
│   │   │       GetComputerUptimeCmdlet.cs
│   │   ├───UI/
│   │   │       WriteAsciiArtCmdlet.cs
│   │   ├───Utility/
│   │   │       FindNonAsciiCharactersCmdlet.cs
│   │   └───Wrapper/
│   │           WinUptimeCmdlet.cs
│   │
│   ├───Models/
│   │       LogSetting.cs
│   │       Cipher.cs
│   │
│   ├───Helpers/
│   │       FileHelper.cs
│   │       LogHelper.cs
│   │       NetworkHelper.cs
│   │
│   └───NoveLib.csproj
├───tests/ (opzionale)
│       NoveLib.Tests.csproj
└───NoveLib.psd1
