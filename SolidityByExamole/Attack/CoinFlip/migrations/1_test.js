const CoinFlip = artifacts.require("CoinFlip");
const CoinFlipAttack = artifacts.require("CoinFlipAttack");

module.exports = function(deployer,network,accounts){
    deployer.deploy(CoinFlip,{from:accounts[1]});
    deployer.deploy(CoinFlipAttack,{from:accounts[1]});


    
    }

    

