const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config.js")
const { network, deployments, ethers } = require("hardhat")
const { assert, expect } = require("chai")

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("VRFJury unit tests", function () {
      let jury, deployer
      beforeEach(async function () {
        ;[deployer] = await ethers.getSigners()
        await deployments.fixture(["all"])
        //vrfMock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
        jury = await ethers.getContract("VRFJury", deployer)
      })
      describe("constructor", function () {
        it("sets vrfCoordinator address correctly", async function () {})
        it("sets keyhash correctly", async function () {})
        it("sets subId correctly", async function () {})
        it("sets callbackGasLimit correctly ", async function () {})
      })
      describe("addCandidate", function () {
        it("reverts if address is already a candidate", async function () {})
        it("adds address to potentialJurors array", async function () {})
        it("sets isPotentialJuror equal to true at given address", async function () {})
      })
      describe("removeCandidate", function () {
        it("reverts if invalid index is provided", async function () {})
        it("sets address at given index equal to address at last index in array", async function () {})
        it("deletes address at last index and decreases array size by 1", async function () {})
      })
      describe("selectJurors", function () {
        /* Might add a custom error for this function */
        it("", async function () {})
        it("calls the vrfCoordinatorV2 correctly", async function () {})
      })
      describe("fulfillRandomWords", function () {
        it("emits JurorsSelected with correct arguments", async function () {})
        it("increments the _counter variable by 1", async function () {})
      })
    })
