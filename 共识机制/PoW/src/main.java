public class main {
    public static void main(String[] args) {
        Block firstBlock = new Block();
        firstBlock.generateFirstBlock("第一个区块");
        System.out.println(firstBlock.toString());
        Block secondBlock = firstBlock.generattNextBlock("第二个区块",firstBlock);
        System.out.println(secondBlock.toString());
    }
}
