import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Encryption {
    //传入文本内容，返回sha-256字符串
    public static String getSha256(final String strText){
        return encryption(strText,"SHA-256");
    }
    public static String encryption(final String strText,final String strType){
        String result = null;
        if(strText != null && strText.length()>0){
            try {
                MessageDigest messageDigest = MessageDigest.getInstance(strType);//实例化
                messageDigest.update(strText.getBytes());//将字符串的字节数组传递给信息摘要进行处理
                byte[] byteBuffer = messageDigest.digest();//
                StringBuilder stringBuilder = new StringBuilder();

                for (byte abyteBuffer : byteBuffer){
                    String hex = Integer.toHexString(0xff&abyteBuffer);
                    if(hex.length()==1){
                        stringBuilder.append('0');

                    }
                    stringBuilder.append(hex);
                }
                result = stringBuilder.toString();
            } catch (NoSuchAlgorithmException e) {
                throw new RuntimeException(e);
            }

        }
        return  result;
    }
}
