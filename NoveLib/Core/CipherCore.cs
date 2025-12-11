using NoveLib.Common.Helpers;
using NoveLib.Global.Constants;
using System;
using System.IO;
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

        internal static string WriteCipherKeyToFile(string keyName, string keyPath, byte[] keyBytes, bool toBase64, bool force)
        {
            // add .key extension
            keyName += CipherConstant.KeyExtension;

            // Create directory
            if (!Directory.Exists(keyPath)) Directory.CreateDirectory(keyPath);

            // Write key on file
            string keyFile = Path.Combine(keyPath, keyName);

            // If file exists and force is false, throw exception
            if (File.Exists(keyFile) && !force)
                throw new IOException("Cipher key file already exists. Use 'Force' option to generate a new one");

            // If file exists and force is true, delete it first
            if (File.Exists(keyFile) && force)
            {
                File.SetAttributes(keyFile, FileAttributes.Normal);
                File.Delete(keyFile);
            }

            // Write key bytes to file
            if (toBase64)
            {
                string base64 = Convert.ToBase64String(keyBytes);
                File.WriteAllText(keyFile, base64, Encoding.UTF8);
            }
            else
                File.WriteAllBytes(keyFile, keyBytes);

            // Set file attributes
            File.SetAttributes(keyFile, FileAttributes.ReadOnly);

            // Return key file path
            return keyFile;
        }

        internal static byte[] ReadCipherKeyFromFile(string keyFile)
        {
            // Helper to check if a string is Base64
            string content;
            try { content = File.ReadAllText(keyFile).Trim(); }
            catch (Exception) { content = null; }

            // Check if content is Base64
            if (!string.IsNullOrEmpty(content) && StringHelper.IsBase64String(content))
            {
                try { return Convert.FromBase64String(content); }
                catch { } // Try to read as raw bytes if conversion fails
            }

            // Read as raw bytes
            try { return File.ReadAllBytes(keyFile); }
            catch (Exception ex)
            {
                throw new InvalidOperationException(
                    $"Unable to read cipher key from file '{keyFile}'. The file is neither valid Base64 text nor valid binary.",
                    ex
                );
            }
        }



        // Encrypt plain text to byte array using AES-256-CBC
        internal static byte[] EncryptToBytes(string plainText, byte[] key)
        {
            using Aes aes = Aes.Create();
            aes.Key = key;
            aes.Mode = CipherMode.CBC;
            aes.Padding = PaddingMode.PKCS7;
            aes.GenerateIV();

            byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);

            using ICryptoTransform encryptor = aes.CreateEncryptor();
            byte[] cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

            byte[] result = new byte[aes.IV.Length + cipherBytes.Length];
            Buffer.BlockCopy(aes.IV, 0, result, 0, aes.IV.Length);
            Buffer.BlockCopy(cipherBytes, 0, result, aes.IV.Length, cipherBytes.Length);

            return result;
        }


    }

#if NET6_0_OR_GREATER
    internal static class SecureCrypto
    {
        private const int KeySizeBytes = 32;      // AES-256
        private const int NonceSizeBytes = 12;    // 96-bit nonce recommended for GCM
        private const int TagSizeBytes = 16;      // 128-bit tag

        // Encrypt: returns nonce + tag + ciphertext
        internal static byte[] EncryptAesGcmToBytes(string plainText, byte[] key, byte[]? associatedData = null)
        {
            if (key is null || key.Length != KeySizeBytes)
                throw new CryptographicException($"Key must be {KeySizeBytes} bytes.");

            byte[] plaintextBytes = Encoding.UTF8.GetBytes(plainText);
            byte[] nonce = new byte[NonceSizeBytes];
            RandomNumberGenerator.Fill(nonce);

            int cipherLen = plaintextBytes.Length;
            byte[] cipherBytes = new byte[cipherLen];
            byte[] tag = new byte[TagSizeBytes];

            try
            {
                using (var aes = new AesGcm(key))
                {
                    if (associatedData != null)
                        aes.Encrypt(nonce, plaintextBytes, cipherBytes, tag, associatedData);
                    else
                        aes.Encrypt(nonce, plaintextBytes, cipherBytes, tag);
                }

                // final layout: [nonce (12)] [tag (16)] [ciphertext (...)]
                byte[] outBuf = new byte[NonceSizeBytes + TagSizeBytes + cipherLen];
                Buffer.BlockCopy(nonce, 0, outBuf, 0, NonceSizeBytes);
                Buffer.BlockCopy(tag, 0, outBuf, NonceSizeBytes, TagSizeBytes);
                Buffer.BlockCopy(cipherBytes, 0, outBuf, NonceSizeBytes + TagSizeBytes, cipherLen);

                return outBuf;
            }
            finally
            {
                // Minimize in-memory lifetime of sensitive data
                CryptographicOperations.ZeroMemory(plaintextBytes);
                CryptographicOperations.ZeroMemory(cipherBytes);
                CryptographicOperations.ZeroMemory(tag);
                CryptographicOperations.ZeroMemory(nonce);
            }
        }

        // Decrypt: input = nonce + tag + ciphertext
        internal static string DecryptAesGcmFromBytes(byte[] input, byte[] key, byte[]? associatedData = null)
        {
            if (key is null || key.Length != KeySizeBytes)
                throw new CryptographicException($"Key must be {KeySizeBytes} bytes.");

            if (input == null || input.Length < NonceSizeBytes + TagSizeBytes)
                throw new CryptographicException("Invalid ciphertext.");

            int cipherLen = input.Length - NonceSizeBytes - TagSizeBytes;
            byte[] nonce = new byte[NonceSizeBytes];
            byte[] tag = new byte[TagSizeBytes];
            byte[] cipherBytes = new byte[cipherLen];
            byte[] plainBytes = new byte[cipherLen];

            try
            {
                Buffer.BlockCopy(input, 0, nonce, 0, NonceSizeBytes);
                Buffer.BlockCopy(input, NonceSizeBytes, tag, 0, TagSizeBytes);
                Buffer.BlockCopy(input, NonceSizeBytes + TagSizeBytes, cipherBytes, 0, cipherLen);

                using (var aes = new AesGcm(key))
                {
                    if (associatedData != null)
                        aes.Decrypt(nonce, cipherBytes, tag, plainBytes, associatedData);
                    else
                        aes.Decrypt(nonce, cipherBytes, tag, plainBytes);
                }

                return Encoding.UTF8.GetString(plainBytes);
            }
            finally
            {
                CryptographicOperations.ZeroMemory(plainBytes);
                CryptographicOperations.ZeroMemory(cipherBytes);
                CryptographicOperations.ZeroMemory(tag);
                CryptographicOperations.ZeroMemory(nonce);
            }
        }

        // Helpers: base64 wrappers
        internal static string EncryptAesGcmToBase64(string plainText, byte[] key, byte[]? aad = null)
            => Convert.ToBase64String(EncryptAesGcmToBytes(plainText, key, aad));

        internal static string DecryptAesGcmFromBase64(string base64Input, byte[] key, byte[]? aad = null)
            => DecryptAesGcmFromBytes(Convert.FromBase64String(base64Input), key, aad);

        // Key generation: random 32 bytes
        internal static byte[] GenerateRandomKey()
        {
            byte[] key = new byte[KeySizeBytes];
            RandomNumberGenerator.Fill(key);
            return key;
        }

        // Key derivation from password (PBKDF2). Returns 32-byte key.
        internal static byte[] DeriveKeyFromPassword(string password, byte[] salt, int iterations = 100_000)
        {
            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations, HashAlgorithmName.SHA256);
            return pbkdf2.GetBytes(KeySizeBytes);
        }
    }
#endif
}
