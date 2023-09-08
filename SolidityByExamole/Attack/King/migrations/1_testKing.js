const  KingOfEther = artifacts.require("KingOfEther");
const Attack = artifacts.require("Attack");


module.exports  = async function (deployer,network,accounts){
    deployer.deploy(KingOfEther,{from:accounts[1]}).then(()=>{
       return deployer.deploy(Attack,KingOfEther.address,{from:accounts[0]})
    })
    // await KingOfEther.deployed();
    // deployer.deploy(Attack,KingOfEther.address,{from:accounts[1]})

}