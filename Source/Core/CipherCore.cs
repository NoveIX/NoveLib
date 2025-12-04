using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace NoveLib.Source.Core
{
    internal class CipherCore
    {
        // Create a new cipher key file
        internal static string CreateCipherKey(string keyName, string keyPath, bool hideKey)
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

            // Set file attributes
            FileAttributes attrs = FileAttributes.ReadOnly;
            if (hideKey) attrs |= FileAttributes.Hidden;
            File.SetAttributes(keyFile, attrs);

            // Return key file path
            return keyFile;
        }

        // ================================================================

        // Encrypt plain text to byte array using AES-256-CBC
        internal static byte[] EncryptToBytes(string plainText, byte[] key)
        {
            // Validate key length
            if (key.Length != 32)
                throw new CryptographicException("Cipher key must be exactly 32 bytes (AES-256).");

            // Create AES instance
            using Aes aes = Aes.Create();
            aes.Key = key;
            aes.Mode = CipherMode.CBC;
            aes.Padding = PaddingMode.PKCS7;
            aes.GenerateIV(); // IV Randomization

            // Prepare memory stream to hold IV + ciphertext
            using MemoryStream ms = new();
            ms.Write(aes.IV, 0, aes.IV.Length); // Prepend IV to the ciphertext

            // Encrypt the plaintext
            using ICryptoTransform encryptor = aes.CreateEncryptor();
            byte[] plainsBytes = Encoding.UTF8.GetBytes(plainText);
            byte[] cipherBytes = encryptor.TransformFinalBlock(plainsBytes, 0, plainsBytes.Length);

            // Write ciphertext to memory stream
            ms.Write(cipherBytes, 0, cipherBytes.Length);

            // Return combined IV + ciphertext
            return ms.ToArray();
        }
    }
}
