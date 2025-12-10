using NoveLib.Global.Constants;
using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace NoveLib.Core
{
    internal class CipherCore
    {
        // Create a new random AES-256 cipher key
        internal static byte[] CreateCipherKey(int keySize)
        {
            // Create a empty byte key
            byte[] keyBytes = new byte[keySize];

            // Use different method to randomize key bytes
#if NET6_0_OR_GREATER
            RandomNumberGenerator.Fill(keyBytes);
#else
            using var rng = new RNGCryptoServiceProvider();
            rng.GetBytes(keyBytes);
#endif

            // Return the key bytes
            return keyBytes;
        }

        // ================================================================

        // Write cipher key to file
        internal static string WriteCipherKeyToFile(string keyName, string keyPath, byte[] keyBytes, bool toBase64, bool force, bool hideKey)
        {
            // add .key extension
            keyName += CipherConstant.KeyExtension;

            // Create directory
            if (!Directory.Exists(keyPath)) Directory.CreateDirectory(keyPath);

            // Write key on file
            string keyFile = Path.Combine(keyPath, keyName);

            // If file exists and force is true, delete it first
            if (File.Exists(keyFile) && force)
            {
                File.SetAttributes(keyFile, FileAttributes.Normal);
                File.Delete(keyFile);
            }

            if (toBase64)
            {
                string base64 = Convert.ToBase64String(keyBytes);
                File.WriteAllText(keyFile, base64, Encoding.UTF8);
            }
            else
                File.WriteAllBytes(keyFile, keyBytes);

            // Set file attributes
            FileAttributes attrs = FileAttributes.ReadOnly;
            if (hideKey) attrs |= FileAttributes.Hidden;
            File.SetAttributes(keyFile, attrs);

            // Return key file path
            return keyFile;
        }

        // ================================================================

        internal static byte[] ReadCipherKeyFromFile(string keyFile)
        {
            // Try reading as text first (Base64 path)
            try
            {
                string content = File.ReadAllText(keyFile).Trim();

                // Quick heuristic: Base64 is ASCII and length multiple of 4
                bool looksLikeBase64 =
                    content.All(c =>
                        (c >= 'A' && c <= 'Z') ||
                        (c >= 'a' && c <= 'z') ||
                        (c >= '0' && c <= '9') ||
                        c == '+' || c == '/' || c == '='
                    )
                    && content.Length % 4 == 0;

                if (looksLikeBase64)
                {
                    try
                    { return Convert.FromBase64String(content); }
                    // content looked like Base64 but wasn't valid → fall back to raw bytes
                    catch
                    { }
                }
            }
            // If reading text fails, fall back to bytes
            catch
            { }

            // Try reading raw bytes
            try
            { return File.ReadAllBytes(keyFile); }
            catch (Exception ex)
            {
                throw new InvalidOperationException(
                    $"Unable to read cipher key from file '{keyFile}'. The file is neither valid Base64 text nor valid binary.",
                    ex
                );
            }
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
