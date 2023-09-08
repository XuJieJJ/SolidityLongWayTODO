const { assert, expect } =require('chai');
const should = require('chai').should();


const Blocker = artifacts.require('Blocker');
const Attack = artifacts.require('Attack');

contract('Blocker', function (accounts){
    let blocker;
    let attack;

    beforeEach(async function (){
        blocker = await Blocker.new();

        const blockerAddress = await blocker.address;
        assert.notEqual(blockerAddress, 0x0);
        expect(blockerAddress).to.have.lengthOf(42);

        attack = await Attack.new(blockerAddress);

        const attackAddress = await attack.address;
        assert.notEqual(attackAddress, 0x0);
        expect(attackAddress).to.have.lengthOf(42);

    })

    it('attack', async () => {      
        await attack.complete1({value: 1e15});
        await attack.complete2();
        const winner = await blocker.winner();
        console.log(winner);
        console.log(attack.address);
        assert.equal(attack.address, winner, "attack failed");

        const score = await blocker.guessFlag();
        console.log(Number(score));
        assert.equal(score,10,"attack failed")
    })
})