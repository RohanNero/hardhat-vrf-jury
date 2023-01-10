const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config.js")
const { network } = require("hardhat")
const { assert, expect } = require("chai")

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("VRFJury unit tests", function () {
      let jury, deployer
      beforeEach(async function () {
        ;[deployer] = await ethers.getSigners()
        const factory = await ethers.getContractFactory("VRFJury", deployer)
        jury = factory.deploy()
      })
      describe("", function () {
        it("", async function () {})
      })
      describe("", function () {
        it("", async function () {})
      })
    })
