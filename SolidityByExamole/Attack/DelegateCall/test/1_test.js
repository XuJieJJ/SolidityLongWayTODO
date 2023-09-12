const {assert, expect} = require('chai');
const should = require('chai').should();


const Lib = artifacts.require('Lib');
const HackMe = artifacts.require('HackMe');
const Attack = artifacts.require('Attack');

contract('HackMe', function(accounts){
    beforeEach(async function(){
        lib = await Lib.new({from: accounts[0]});
        const address = await lib.address;
        hackMe = await HackMe.new(address, {from: accounts[0]}); 
    })

    it('deploy contracts', async () => {
        const libAddress = await lib.address;
        const hackMeAddress = await hackMe.address;

        assert.notEqual(libAddress, 0x0);
        assert.notEqual(hackMeAddress, 0x0);

        expect(libAddress).to.have.lengthOf(42);
        expect(hackMeAddress).to.have.lengthOf(42);
    })

    it('simulate attack', async () => {
        const hackMeAddress = await hackMe.address;
        const libAddress = await lib.address;
        console.log("the address of hackMe contract:",hackMeAddress);
        console.log("the address of lib contract:", libAddress);

        const attack = await Attack.new(hackMeAddress, {from:accounts[1]});

        const rightHackMeOwner = await hackMe.owner();
        const rightLibAddress = await hackMe.lib();
        console.log("before attack,the owner of hackMe is:", rightHackMeOwner);
        console.log("before attack, the address of hackMe's lib is:", rightLibAddress);

        assert.equal(rightHackMeOwner, accounts[0], 'before attack, the owner of hackMe should be right');
        assert.equal(rightLibAddress, libAddress, 'before attack, the address of hackMe\'s lib should be right')

        await attack.attack();

        const afterAttackHackMeOwner = await hackMe.owner();
        const afterAttackLibAddress = await hackMe.lib();
        console.log("after attack,the owner of hackMe is:", afterAttackHackMeOwner);
        console.log("after attack, the address of hackMe's lib is:", afterAttackLibAddress);

        const attackAddress = await attack.address;
        console.log("attacker is:", accounts[1]);
        console.log("the address of attack contract is:", attackAddress);

        assert.equal(afterAttackHackMeOwner, accounts[1], 'after attack, the owner of hackMe has become the attacker');
        assert.equal(afterAttackLibAddress, attackAddress, 'after attack, the address of hackMe\'s lib has become the address of attack contract')
    })
})