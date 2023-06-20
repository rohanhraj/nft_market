const hre = require("hardhat")

async function main(){
  const Market = await hre.ethers.getContractFactory("NFTMarket")
  const market = await Market.deploy();
  await market.deployed()

  console.log("NFTmarket deployed to address:",market.address)

  const NFT = await hre.ethers.getContractFactory("NFT")
  const nft = await NFT.deploy(market.address);
  await nft.deployed();

  console.log("NFT deployed to address:",nft.address)

}

main().catch((error) =>
{
  console.error(error);
  process.exitCode = 1  
})