const {assert,expect} =require("chai");

const Bank = artifacts.require("Bank");
const Attack = artifacts.require("Attack");

contract("Test attack contract",async function(accounts){
    let bank,attack;
    beforeEach(async function(){
        bank = await Bank.deployed();
        attack = await Attack.deployed();

    });
    it("should deploy successfully",async ()=>{
        assert.notEqual(bank.address,0x0,'failed to deploy contract bank');
        assert.notEqual(attack.address,0x0,'failed to deploy contract attack');

        expect(bank.address).to.have.lengthOf(42);
        expect(attack.address).to.have.lengthOf(42);
    })
    it("should attack success", async ()=>{
        const balanceOfAccount1Before =await web3.eth.getBalance(accounts[0]);
        const balanceOfAccount2Before =await web3.eth.getBalance(accounts[1]);

        console.log("balanceOfAccount1 have :",Number(balanceOfAccount1Before))
        console.log("balanceOfAccount2 have :",Number(balanceOfAccount2Before))
        const balanceOfBank = await web3.eth.getBalance(bank.address);
        assert.equal(Number(balanceOfBank),web3.utils.toWei('10','ether'),'bank should have 10eth');
        
        await attack.attack({from:accounts[0]});

        const balanceOfAccount1After =await web3.eth.getBalance(accounts[0]);
        const balanceOfAccount2After =await web3.eth.getBalance(accounts[1]);

        console.log("After attack balanceOfAccount2 have :",Number(balanceOfAccount2After))

        const balanceOfBankAfter =await web3.eth.getBalance(bank.address);
        assert.equal(balanceOfBankAfter,web3.utils.toWei('0','ether'),'bank should have 0eth');




    })

})