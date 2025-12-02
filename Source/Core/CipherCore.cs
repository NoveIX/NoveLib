using System.IO;
using System.Security.Cryptography;

namespace NoveLib.Source.Core
{
    internal class CipherCore
    {
        internal static string CreateCipherKey(string keyName, string keyPath)
        {
            // add .key extension
            keyName += ".key";

            // Create a empty byte key
            byte[] keyLenght = new byte[32];

            // Use different method to randomize key bytes
#if NET6_0_OR_GREATER
            RandomNumberGenerator.Fill(keyLenght);
#else
            using var rng = new RNGCryptoServiceProvider();
            rng.GetBytes(keyLenght);
#endif
            // Create directory
            if (!Directory.Exists(keyPath)) Directory.CreateDirectory(keyPath);

            // Write key on file
            string keyFile = Path.Combine(keyPath, keyName);
            File.WriteAllBytes(keyFile, keyLenght);

            // Return key file path
            return keyFile;
        }
    }
}
