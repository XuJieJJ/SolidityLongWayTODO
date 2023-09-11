const {assert, expect} = require('chai');
const should = require('chai').should();

const Shop = artifacts.require('Shop');
const ShopAttack = artifacts.require('ShopAttack');

contract('Shop', function(accounts){
    let shop;

    beforeEach(async function(){
        shop = await Shop.new({from:accounts[0]});
        shopAttack = await ShopAttack.new({from:accounts[1]});
    });

    it('deploy contracts', async () => {
        assert.notEqual(shop.address, 0x0, 'failed to deploy contract shop!');
        assert.notEqual(shopAttack.address, 0x0, 'failed to deploy contract shopAttack!');

        expect(shop.address).to.have.lengthOf(42);
        expect(shopAttack.address).to.have.lengthOf(42);
    })

    it('attack', async () => {
        console.log(shop.address);
        console.log(shopAttack.address);

        await shopAttack.attack(shop.address,{from:accounts[1]});    

        const goodsOwner = await shop.goodsOwner();
        console.log(goodsOwner);
        assert.equal(goodsOwner, shopAttack.address, "Failed to bid!");
        
        const price = await shop.price();
        assert.equal(Number(price), 1, "failed to attack!");
    })

})