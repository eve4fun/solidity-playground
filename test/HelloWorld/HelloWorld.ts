import chai from "chai";
import chaiAsPromised from "chai-as-promised";
import BigNumber from "bignumber.js";
import {
  getTransactionFee,
  getMockExternalContract,
} from "../test-util";
import { AddressZero } from "@ethersproject/constants";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
const { assert, expect } = chai;
chai.use(chaiAsPromised);

describe("HelloWorld", function () {
  let signers: Signer[];
  const isDebugMode = false;
  let helloWorld: Contract;
  let byeWorld: Contract;
  let weth: Contract;
  let deployer: Signer;
  before(async () => {
    signers = await ethers.getSigners();
    deployer = signers[0];
    weth = await getMockExternalContract("WETH", deployer);
    const someBalance = new BigNumber((await deployer.getBalance()).toString()).dividedToIntegerBy(2).toString(10);
    await weth.deposit({ value: `${someBalance}` });
  });
  beforeEach(async () => {
    helloWorld = await (await ethers.getContractFactory("HelloWorld")).deploy();
    byeWorld = await (await ethers.getContractFactory("ByeWorld")).deploy(weth.address);
  });

  beforeEach(async function () {
    signers = await ethers.getSigners();
  });

  describe("testSomething", async () => {
    it("should update helloWorld.addressToStore", async function () {
      // checking before testing
      assert.deepEqual(await helloWorld.addressToStore(), AddressZero);
      // testSomething
      const transaction = await helloWorld.testSomething(weth.address);
      if (isDebugMode) {
        console.log(await getTransactionFee(transaction));
      }
      assert.deepEqual(await helloWorld.addressToStore(), weth.address);
    });
  });
  describe("testRevert", () => {
    it("should revert when testRevert", async function () {
      try {
        await helloWorld.testRevert();
      } catch (err : any) {
        expect(err.message).contains("HelloWorld:testRevert: should XXXXXXX some reason for explain");
      }
    });
  });
});
