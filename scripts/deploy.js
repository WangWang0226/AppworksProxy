
const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {

  const ProxyV1 = await ethers.getContractFactory("AppWorksProxyV1")
  
  console.log("正在發佈 AppWorksProxyV1 ...")
  const proxy = await upgrades.deployProxy(ProxyV1)
  await proxy.deployed();
  
  console.log("Proxy 合約地址", proxy.address)
  console.log("等待兩個網路確認 ... ")
  const receipt = await proxy.deployTransaction.wait(2);

  console.log("管理合約地址 getAdminAddress", await upgrades.erc1967.getAdminAddress(proxy.address))
  console.log("邏輯合約地址 getImplementationAddress", await upgrades.erc1967.getImplementationAddress(proxy.address))    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
