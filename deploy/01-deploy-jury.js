const { deployments, getNamedAccounts, network, ethers } = require("hardhat")
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config.js")

module.exports = async ({ deployments, getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts()
  const { deploy, log } = deployments
  const chainId = await getChainId()
  //log(chainId)

  if (developmentChains.includes(network.name)) {
    vrfCoordinator = await ethers.getContract("VRFCoordinatorV2Mock")
    vrfCoordinatorAddress = vrfCoordinator.address
  } else {
    vrfCoordinatorAddress = networkConfig[chainId]["vrfCoordinator"]
  }

  args = [
    vrfCoordinatorAddress,
    networkConfig[chainId]["keyHash"],
    networkConfig[chainId]["subId"],
    networkConfig[chainId]["callbackGaslimit"],
  ]

  const jury = await deploy("VRFJury", {
    from: deployer,
    log: true,
    args: args,
  })
}

module.exports.tags = ["all", "main"]
