import java.sql.Timestamp;

public class Block {
    private String preHash;
    private String hashCode;
    //时间戳
    private Timestamp timestamp;
    private int diff;//难度
    //交易信息
    private  String data;
    //区块高度
    private int index;
    //随机值
    private  int nonce;


    public String getPrehash(){
        return preHash;
    }
    public void setPreHash(String preHash){
        this.preHash=preHash;
    }
    public  String  getHashCode(){
        return  hashCode;
    }
    public void setHashCode(String hashcode){
        this.hashCode=hashcode;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    public int getDiff() {
        return diff;
    }

    public void setDiff(int diff) {
        this.diff = diff;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public int getNonce() {
        return nonce;
    }

    public void setNonce(int nonce) {
        this.nonce = nonce;
    }

    @Override
    public String toString() {
        return "Block{" +
                "preHash='" + preHash + '\'' +
                ", hashCode='" + hashCode + '\'' +
                ", timestamp=" + timestamp +
                ", diff=" + diff +
                ", data='" + data + '\'' +
                ", index=" + index +
                ", nonce=" + nonce +
                '}';
    }
    public Block generateFirstBlock(String data){
        this.preHash="0";
        this.timestamp=new Timestamp(System.currentTimeMillis());
        this.diff =4;
        this.data=data;
        this.index=1;
        this.nonce=0;
        this.hashCode=this.generationHashCodeBySha256();
        return  this;
    }
    public String generationHashCodeBySha256(){
        String hashData =""+ this.index + this.nonce+this.diff+this.timestamp;
        return Encryption.getSha256(hashData);

    }

    public static void main(String[] args) {
        Block block = new Block();
        block.generateFirstBlock("第一个区块");
        System.out.println(block.toString());
    }



    public Block generattNextBlock(String data,Block oldBlock){
        Block newblock = new Block();
        newblock.setTimestamp(new Timestamp(System.currentTimeMillis()));
        newblock.setDiff(4);
        newblock.setData(data);
        newblock.setIndex(oldBlock.getIndex()+1);
        newblock.setPreHash(oldBlock.getHashCode());

        newblock.setNonce(0);
        newblock.setHashCode(PowAlgorithm.pow(newblock.getDiff(),newblock));
        return newblock;
    }

}






















