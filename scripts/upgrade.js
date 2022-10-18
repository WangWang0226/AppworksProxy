const { ethers, upgrades } = require("hardhat");

const proxyAddress = '0x2876bB144Aca31860e9F2B1583628564cA57deAB'

async function main() {

  console.log("指定的Proxy 合約地址", proxyAddress)

  const NFTV2 = await ethers.getContractFactory("AppWorksProxyV2")
  console.log("升級合約進行中...")

  const proxy = await upgrades.upgradeProxy(proxyAddress, NFTV2)
  console.log("Proxy 合約地址", proxy.address)

  console.log("等待2個網路確認 ... ")
  const receipt = await proxy.deployTransaction.wait(2);
  
  console.log("管理合約地址 getAdminAddress", await upgrades.erc1967.getAdminAddress(proxy.address))  
  console.log("邏輯合約地址 getImplementationAddress", await upgrades.erc1967.getImplementationAddress(proxy.address))

}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})