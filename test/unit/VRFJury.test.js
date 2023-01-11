const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config.js")
const { network, deployments, ethers } = require("hardhat")
const { assert, expect } = require("chai")

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("VRFJury unit tests", function () {
      let jury, deployer, vrfMock
      beforeEach(async function () {
        ;[deployer, pat, rick] = await ethers.getSigners()
        await deployments.fixture(["all"])
        vrfMock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
        jury = await ethers.getContract("VRFJury", deployer)
      })
      describe("constructor", function () {
        it("sets vrfCoordinator address correctly", async function () {
          const val = await jury.viewCoordinatorAddress()
          assert.equal(val, vrfMock.address)
        })
        it("sets keyhash correctly", async function () {
          const val = await jury.viewKeyHash()
          assert.equal(
            val,
            "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15"
          )
        })
        it("sets subId correctly", async function () {
          const val = await jury.viewSubId()
          assert.equal(val, 1)
        })
        it("sets callbackGasLimit correctly ", async function () {
          const val = await jury.viewCallbackGasLimit()
          assert.equal(val, 500000)
        })
      })
      describe("addCandidate", function () {
        it("reverts if address is already a candidate", async function () {
          await jury.addCandidate(deployer.address)
          await expect(jury.addCandidate(deployer.address))
            .to.be.revertedWithCustomError(jury, "VRFJury__AddressAlreadyAdded")
            .withArgs(deployer.address)
        })
        it("adds address to potentialJurors array", async function () {
          const val = await jury.viewPotentialJurorsLength()
          await jury.addCandidate(deployer.address)
          const newVal = await jury.viewPotentialJurorsLength()
          assert.equal(val.add(1).toString(), newVal.toString())
        })
        it("sets isPotentialJuror equal to true at given address", async function () {
          const val = await jury.viewJurorStatus(deployer.address)
          await jury.addCandidate(deployer.address)
          const newVal = await jury.viewJurorStatus(deployer.address)
          assert.notEqual(val, newVal)
        })
      })
      describe("removeCandidate", function () {
        beforeEach(async function () {
          await jury.addCandidate(deployer.address)
          await jury.addCandidate(pat.address)
          await jury.addCandidate(rick.address)
        })
        it("reverts if invalid index is provided", async function () {
          await expect(jury.removeCandidate(777))
            .to.be.revertedWithCustomError(jury, "VRFJury__InvalidIndex")
            .withArgs(777)
        })
        it("sets isPotentialJuror equal to false at removed address", async function () {
          const val = await jury.viewJurorStatus(deployer.address)
          await jury.removeCandidate(0)
          const newVal = await jury.viewJurorStatus(deployer.address)
          assert.notEqual(val, newVal)
        })
        it("sets address at given index equal to address at last index in array", async function () {
          const val = await jury.viewJurorAddress(0)
          await jury.removeCandidate(0)
          const newVal = await jury.viewJurorAddress(0)
          assert.equal(newVal, rick.address)
        })
        it("deletes address at last index and decreases array size by 1", async function () {
          const val = await jury.viewPotentialJurorsLength()
          await jury.removeCandidate(0)
          const newVal = await jury.viewPotentialJurorsLength()
          assert.equal(val.sub(1).toString(), newVal.toString())
        })
      })
      describe("selectJurors", function () {
        /* Might add a custom error for this function */
        it("", async function () {})
        it("calls the vrfCoordinatorV2 correctly", async function () {
          const subId = await jury.viewSubId()
          const val = await vrfMock.getSubscription(1)
          await vrfMock.addConsumer(1, jury.address)
          await expect(jury.selectJurors(1))
            .to.emit(jury, "RandomWordsRequested")
            .withArgs(1)
        })
      })
      describe("fulfillRandomWords", function () {
        it("emits JurorsSelected with correct arguments", async function () {
          await jury.addCandidate(deployer.address)
          const length = await jury.viewPotentialJurorsLength()
          //console.log(length)
          const addr = await jury.viewJurorAddress(0)
          //console.log(addr)
          await vrfMock.addConsumer(1, jury.address)
          await jury.selectJurors(1)
          const args = [deployer.address]
          await expect(vrfMock.fulfillRandomWords(1, jury.address)).to.emit(
            jury,
            "JurorsSelected"
          )
        })
        it("increments the _counter variable by 1", async function () {
          await jury.addCandidate(deployer.address)
          const val = await jury.viewCounter()
          await vrfMock.addConsumer(1, jury.address)
          await jury.selectJurors(1)
          await vrfMock.fulfillRandomWords(1, jury.address)
          const newVal = await jury.viewCounter()
          assert.equal((val + 1).toString(), newVal.toString())
        })
      })
    })
