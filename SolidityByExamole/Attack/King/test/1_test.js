const {assert} = require("chai");

const KingOfEther = artifacts.require("KingOfEther")
const Attack = artifacts.require("Attack");


contract("Test  Attack Contract ",async function(accounts){
    let kingOfEther,attack;
    beforeEach(async ()=>{
        kingOfEther = await KingOfEther.deployed();
        attack = await Attack.deployed();

    })
    it("Test normal conditions",async ()=>{
        //account[0] tobe king
        await kingOfEther.claimThrone({from:accounts[0],value:web3.utils.toWei('1','ether')});
        const balance1 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance1)
        assert.equal(accounts[0],await kingOfEther.king(),"account[0] isn't king success")

        //account[1] tobe king
        await kingOfEther.claimThrone({from:accounts[1],value:web3.utils.toWei('2','ether')});
        const balance2 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance2)
        assert.equal(accounts[1],await kingOfEther.king(),"account[1] isn't king success")

        //account[2] tobe king
        await kingOfEther.claimThrone({from:accounts[2],value:web3.utils.toWei('3','ether')});
        const balance3 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance3)
        assert.equal(accounts[2],await kingOfEther.king(),"account[2] tobe king failed")

        //account[3] not tobe the king becauseof the less deposit

        
        try {
            await kingOfEther.claimThrone({from:accounts[3],value:web3.utils.toWei('2','ether')});
            assert.equal(accounts[2],await kingOfEther.king(),"account[3] become king failed")
        } catch (error) {
            const balance4 = await web3.eth.getBalance(kingOfEther.address);
            console.log(balance4)
            assert.equal(error.reason,'Need to pay more to become the king');
            return
        }
        

    });

    it("The bad people should attack successfully",async ()=>{
        //account[0] tobe king
        await kingOfEther.claimThrone({from:accounts[0],value:web3.utils.toWei('4','ether')});
        const balance1 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance1)
        assert.equal(accounts[0],await kingOfEther.king(),"account[0] isn't king success")

        //account[1] tobe king
        await kingOfEther.claimThrone({from:accounts[1],value:web3.utils.toWei('5','ether')});
        const balance2 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance2)
        assert.equal(accounts[1],await kingOfEther.king(),"account[1] isn't king success")

        //attack 
        await attack.attack({from:accounts[2],value:web3.utils.toWei('6','ether')});
        const balance3 = await web3.eth.getBalance(kingOfEther.address);
        console.log(balance3)
        assert.equal(attack.address,await kingOfEther.king(),"account[1] isn't king success")

        try {
            await kingOfEther.claimThrone({from:accounts[1],value:web3.utils.toWei('7','ether')});
        } catch (error) {
            const balance4 = await web3.eth.getBalance(kingOfEther.address);
            console.log(balance4)
            assert.equal(error.reason,'Failed to send Ether');
        }
        
        
    })

})