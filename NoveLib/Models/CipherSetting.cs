namespace NoveLib.Models
{

    public class CipherSetting(string keyFile, string textFile, object cipherData)
    {
        public string KeyFile { get; set; } = keyFile;
        public string TextFile { get; set; } = textFile;
        public object CipherData { get; set; } = cipherData;
        public CipherSetting() : this(null, null, null) { }
    }
}

