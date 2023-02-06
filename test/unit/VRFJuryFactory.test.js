const { assert, expect } = require("chai")
const { network } = require("hardhat")
const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config.js")

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("VRFJuryFactory Unit tests")
