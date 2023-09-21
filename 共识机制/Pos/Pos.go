package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/rand"
	"strconv"
	"time"
)

type Block struct {
	Index     int
	Data      string
	PreHash   string
	Hash      string
	TimeStamp string
	Validator *Node
}

type Node struct {
	Tokens  int
	Days    int
	Address string
}

//init
func genesisBlock() Block {
	var genesBlock = Block{
		0, "Genesis block", "", "", time.Now().String(), &Node{0, 0, "address0"}}
	genesBlock.Hash = hex.EncodeToString(BlockHash(&genesBlock))
	return genesBlock
}

func BlockHash(block *Block) []byte {
	record := strconv.Itoa(block.Index) + block.Data + block.PreHash + block.TimeStamp + block.Validator.Address
	h := sha256.New()
	h.Write([]byte(record))
	hashed := h.Sum(nil)
	return hashed
}

var nodes = make([]Node, 5)

var addrs = make([]*Node, 15)

func InitNodes() {
	nodes[0] = Node{1, 1, "0x1"}
	nodes[0] = Node{2, 1, "0x2"}
	nodes[0] = Node{3, 1, "0x3"}
	nodes[0] = Node{4, 1, "0x4"}
	nodes[0] = Node{5, 1, "0x5"}

	cnt := 0
	for i := 0; i < 5; i++ {
		for j := 0; j < nodes[i].Tokens*nodes[i].Days; j++ {
			addrs[cnt] = &nodes[i]
			cnt++
		}
	}

}

func CreateNewBlock(lastblock *Block, data string) Block {
	var newBlock Block
	newBlock.Index = lastblock.Index + 1
	newBlock.TimeStamp = time.Now().String()
	newBlock.PreHash = lastblock.Hash
	newBlock.Data = data
	//设置种子
	rand.Seed(time.Now().Unix())
	var rd = rand.Intn(15)

	node := addrs[rd]
	newBlock.Validator = node
	node.Tokens += 1
	newBlock.Hash = hex.EncodeToString(BlockHash(&newBlock))

	return newBlock

}

func main() {

	InitNodes()

	//创建创世区块
	var genesisBlock = genesisBlock()
	//init block
	var newBLock = CreateNewBlock(&genesisBlock, "newBlock")

	fmt.Println(newBLock)
	fmt.Println("------------------------------")
	fmt.Println(newBLock.Validator.Tokens)
	fmt.Println("------------------------------")
	fmt.Println(newBLock.Validator.Address)

}
