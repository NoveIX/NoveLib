namespace NoveLib.Models
{
    /// <summary>
    /// Represents the configuration for an AES cipher operation, including key file path, encrypted text file path, and
    /// in-memory cipher data.
    /// </summary>
    /// <param name="keyFile">The path to the AES key file used for encryption or decryption. Can be null if not applicable.</param>
    /// <param name="textFile">The path to the encrypted text file, if the encrypted data is saved to a file. Can be null if the data is not
    /// stored in a file.</param>
    /// <param name="cipherData">The encrypted data, provided as a Base64-encoded string or a byte array, if not saved to a file. Can be null if
    /// the data is stored in a file.</param>
    public class CipherSetting(string keyFile, string textFile, object cipherData)
    {
        /// <summary>
        /// Gets or sets the path of the AES key file.
        /// </summary>
        public string KeyFile { get; set; } = keyFile;

        /// <summary>
        /// Gets or sets the path of the encrypted text file, if saved.
        /// </summary>
        public string TextFile { get; set; } = textFile;

        /// <summary>
        /// Gets or sets the encrypted data (Base64 string or byte[]), if not saved to file.
        /// </summary>
        public object CipherData { get; set; } = cipherData;

        /// <summary>
        /// Initializes a new instance of the CipherSetting class with default values.
        /// </summary>
        public CipherSetting() : this(null, null, null) { }
    }
}

