using System.Linq;

namespace NoveLib.Common.Helpers
{
    internal class StringHelper
    {
        internal static bool IsBase64String(string s)
        {
            if (string.IsNullOrWhiteSpace(s) || s.Length % 4 != 0)
                return false;

            return s.All(c =>
                (c >= 'A' && c <= 'Z') ||
                (c >= 'a' && c <= 'z') ||
                (c >= '0' && c <= '9') ||
                c == '+' || c == '/' || c == '='
            );
        }
    }
}
