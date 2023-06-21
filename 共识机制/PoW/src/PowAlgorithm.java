public class PowAlgorithm {
    public static String pow(int diff,Block block){
        String prefix0 = getPrefix0(diff);
        String hash = block.generationHashCodeBySha256();
        while(true){
            System.out.println(hash);
            assert prefix0!=null;
            if(hash.startsWith(prefix0)){
                System.out.println("挖矿成功");
                return hash;
            }else {
                block.setNonce((block.getNonce()+1));
                hash = block.generationHashCodeBySha256();
            }
        }
    }






    private static String getPrefix0(int diff){
        if(diff<0){
            return null;

        }
        return String.format("%0"+diff+"d",0);
    }
}
