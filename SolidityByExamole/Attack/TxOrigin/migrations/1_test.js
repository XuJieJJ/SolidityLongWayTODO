const Bank = artifacts.require("Bank");
const Attack = artifacts.require("Attack");

module.exports = async function (deployer, network, accounts) {
  // 部署 Bank 合约
  await deployer.deploy(Bank, { from: accounts[0], value: web3.utils.toWei("10", "ether") });

  // 获取已部署的 Bank 合约实例
  const bankInstance = await Bank.deployed();

  // 部署 Attack 合约，传入 Bank 合约地址
  await deployer.deploy(Attack, bankInstance.address, { from: accounts[1] });

  console.log("Bank contract deployed to:", Bank.address);
  console.log("Attack contract deployed to:", Attack.address);
};
