const  {assert,expect} = require("chai");
const should = require('chai').should();
const Adoption = artifacts.require("Adoption");


contract("test adoption",function(accounts){
    let adoption;
    beforeEach(async function(){
        adoption = await Adoption.deployed();
    });
    it("deploy",async ()=>{
        const address = await adoption.address;
        assert.notEqual(address,0x0);
        expect(address).to.have.lengthOf(42);
    })
    it("test adopt",async ()=>{
       await adoption.adopter(1,{from:accounts[0]});
       const adoptedBy = await adoption.adopters(1)
        
       const expected = 1;
        
        assert.equal(adoptedBy,accounts[0],"adoption shouled same");
    })
})