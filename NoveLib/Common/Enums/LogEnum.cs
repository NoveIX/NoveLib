namespace NoveLib.Source.Common.Enums
{
    public enum LogLevel
    {
        Trace,  // Maximum details
        Debug,  // Debug info
        Info,   // General information
        Warn,   // Warnings
        Error,  // Errors
        Fatal,  // Critical errors
        Done    // Successfully completed
    }

    public enum LogFormat
    {
        Default,    // [yyyy-MM-dd HH:mm:ss] [Level]: Message
        Simple,     // [Level]: Message
        Detailed,   // [yyyy-MM-dd HH:mm:ss.fff] [Level] [SourceContext]: Message
        Compact,    // HH:mm:ss Level: Message
        ISO8601,     // [yyyy-MM-ddTHH:mm:ss.fffzzz] [Level] [SourceContext]: Message (UTC)
        Verbose     // [yyyy-MM-ddTHH:mm:ss.fffzzz] [Level] [SourceContext] [File:Line]: Message (UTC)
    }

    public enum LogDate
    {
        None,               // logname.log
        DateCompact,        // logname_20251024.log
        DateHyphen,         // logname_2025-10-24.log           //ISO 8601 Date
        DateTimeCompact,    // logname_20251024_143000.log
        DateTimeHyphen      // logname_2025-10-24_14-30-00.log  //ISO 8601 DateTime
    }
}
