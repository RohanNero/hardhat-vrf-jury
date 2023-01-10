const networkConfig = {
  31337: {
    name: "localhost",
    keyHash:
      "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    subId: "777",
    blockConfirmations: "5",
    callbackGaslimit: "500000",
    vrfCoordinator: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
  },
  5: {
    name: "goerli",
    keyHash:
      "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    subId: "777",
    blockConfirmations: "5",
    callbackGaslimit: "500000",
    vrfCoordinator: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
  },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
  developmentChains,
  networkConfig,
}
