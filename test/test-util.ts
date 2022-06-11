import { Signer } from "ethers";
import { ethers } from "hardhat";

const fs = require("fs");
const BigNumber = require("bignumber.js");

export async function getMockExternalContract (fileName: string, deployer: Signer, args?: any[]) {
  return await getMockContractByArtifact(
    JSON.parse(fs.readFileSync(`artifacts-external/${fileName}.json`, "utf-8")),
    deployer, args);
}

export async function getTransactionFee (transaction: any) {
  const transactionReceipt = await (transaction).wait();
  return new BigNumber(transaction.gasPrice.toString()).multipliedBy(
    transactionReceipt.gasUsed.toString(),
  ).toString(10);
}

export async function getMockContractByArtifact (artifact: any, deployer: Signer, args?: any[]) {
  const Factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, deployer);
  let factory;
  if (!args) {
    factory = await Factory.deploy();
  } else {
    factory = await Factory.deploy(...args);
  }
  await factory.deployed();
  return factory;
}
