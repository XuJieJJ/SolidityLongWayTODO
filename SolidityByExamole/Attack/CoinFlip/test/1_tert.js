const assert = require("chai");
const CoinFlip = artifacts.require("CoinFlip");
const CoinFlipAttack = artifacts.require("CoinFlipAttack");


contract("Attack CoinFlip should success ",async function(accounts){
    let coinFlip , coinFlipAttack;
    beforeEach(async function(){
        coinFlip = await CoinFlip.deployed();
        coinFlipAttack = await CoinFlipAttack.deployed();
    });
    it("Testing CoinFlip normal flow conditions",async function(){
        const boolTrue = 1;
        const boolFalse = 0;
        console.log("参与者============")
        console.log(accounts[2]);
        await coinFlip.flip(boolTrue,{from:accounts[2]});
        var consecutiveWins = await coinFlip.consecutiveWins();
        console.log(Number(consecutiveWins));
        await coinFlip.flip(boolTrue,{from:accounts[2]});
        consecutiveWins = await coinFlip.consecutiveWins();
        console.log(Number(consecutiveWins));
        await coinFlip.flip(boolTrue,{from:accounts[2]});
        consecutiveWins = await coinFlip.consecutiveWins();
        console.log(Number(consecutiveWins));
        await coinFlip.flip(boolTrue,{from:accounts[2]});
        consecutiveWins = await coinFlip.consecutiveWins();
        console.log(Number(consecutiveWins));

        
    });
    it("Simulated Attacker Engagement Game",async function(){

        await coinFlipAttack.attack(coinFlip.address);
        await coinFlipAttack.attack(coinFlip.address);
        await coinFlipAttack.attack(coinFlip.address);
        await coinFlipAttack.attack(coinFlip.address);
        await coinFlipAttack.attack(coinFlip.address);
        var consecutiveWins = await coinFlip.consecutiveWins();
        console.log(Number(consecutiveWins));
    })
})