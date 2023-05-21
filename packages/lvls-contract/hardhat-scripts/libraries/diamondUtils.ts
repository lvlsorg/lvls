/* global ethers */
import type { Contract } from "ethers";
import path from "path";
import { getSelectors } from "./diamond";
import fs from "fs-extra";
import { forEach } from "lodash";
import { keccak256 } from "ethers/lib/utils";
// import {ethers} from "hardhat"

// const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }
export enum FacetCutAction {
  Add = 0,
  Replace = 1,
  Remove = 2,
}

export interface DiamondCoreDeployed {
  diamondCutFacet: Contract;
  registerDiamondCutFacet: Contract;
  diamondLoupeFacet: Contract;
  diamond: Contract;
  diamondInit: Contract;
  diamondLauncherFacet: Contract;
}

export type FacetContracts = Record<string, Contract>;

export type FacetContractNames = string[];
export interface RegisterCut {
  id: Uint8Array;
  facetCut: Cut;
}
export interface Cut {
  facetAddress: string;
  action: FacetCutAction;
  functionSelectors: string[];
}

export interface FacetCut {
  name: string;
  cut: Cut;
}

export type DeploymentConfig = Record<number, Record<string, string>>;

const CONFIG_DEFAULT_PATH = "./src/generated/deployed.json";
// Read deployed.json configuration
export async function getDeploymentConfig(
  configPath: string
): Promise<DeploymentConfig> {
  try {
    const result = await fs.promises.readFile(path.resolve(configPath));
    return result ? JSON.parse(result.toString()) : {};
  } catch (e) {
    return {};
  }
}

export interface FacetConfigs {
  [k: string]: string;
}

export async function setFacetSubscription(
  diamondAddr: string,
  facetIds: Uint8Array[]
) {
  const diamond = await ethers.getContractAt("Diamond", diamondAddr);
  return diamond.setFacetSubscription(facetIds);
}

export async function setDeploymentConfigFacets(
  configPath: string,
  chainId: number,
  facetConfigs: FacetConfigs,
  facetCuts: FacetCut[]
) {
  const config = await getDeploymentConfig(configPath);
  facetCuts.forEach(
    (facetCut) =>
      //TODO fix typing here
      ((facetConfigs as any)[facetCut.name] = facetCut.cut.facetAddress)
  );
  config[chainId] = facetConfigs;
  await fs.promises.writeFile(
    path.resolve(configPath),
    JSON.stringify(config, null, 2)
  );
}
// Write deployed.json configuration
export async function setDeploymentConfig(
  configPath: string,
  chainId: number,
  coreDiamond: DiamondCoreDeployed,
  facetCuts: FacetCut[]
) {
  const deployedMap = {
    Diamond: coreDiamond.diamond.address,
    DiamondCutFacet: coreDiamond.diamondCutFacet.address,
    DiamondLoupeFacet: coreDiamond.diamondLoupeFacet.address,
    DiamondInitFacet: coreDiamond.diamondInit.address,
    DiamondLauncherFacet: coreDiamond.diamondLauncherFacet.address,
  };
  setDeploymentConfigFacets(configPath, chainId, deployedMap, facetCuts);
}

export async function deployDiamondCore(): Promise<DiamondCoreDeployed> {
  console.log("in deployDiamond");
  const accounts = await ethers.getSigners();
  console.log(await accounts[0].getAddress());
  const contractOwner = accounts[0];

  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
  const diamondCutFacet = await DiamondCutFacet.deploy();
  await diamondCutFacet.deployed();
  console.log("DiamondCutFacet deployed:", diamondCutFacet.address);

  // deploy DiamondCutFacet
  const RegisterDiamondCutFacet = await ethers.getContractFactory(
    "RegisterDiamondCutFacet"
  );
  const registerDiamondCutFacet = await RegisterDiamondCutFacet.deploy();
  await registerDiamondCutFacet.deployed();
  console.log(
    "RegisterDiamondCutFacet deployed:",
    registerDiamondCutFacet.address
  );

  // depploy DiamondLoupeFacet
  const DiamondLoupeFacet = await ethers.getContractFactory(
    "DiamondLoupeFacet"
  );
  const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
  await diamondLoupeFacet.deployed();
  console.log(`DiamondLoupeFacet deployed: ${diamondLoupeFacet.address}`);

  // depploy DiamondLauncherFacet
  const DiamondLauncherFacet = await ethers.getContractFactory(
    "DiamondLauncherFacet"
  );
  const diamondLauncherFacet = await DiamondLoupeFacet.deploy();
  await diamondLauncherFacet.deployed();
  console.log(`DiamondLauncherFacet deployed: ${diamondLoupeFacet.address}`);

  // deploy Diamond
  const Diamond = await ethers.getContractFactory("Diamond");
  // diamondLoupeFacet.address
  const diamond = await Diamond.deploy(
    contractOwner.address,
    diamondCutFacet.address,
    registerDiamondCutFacet.address,
    diamondLoupeFacet.address
  );
  await diamond.deployed();
  console.log("Diamond deployed:", diamond.address);

  // deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInit = await ethers.getContractFactory("DiamondInit");
  const diamondInit = await DiamondInit.deploy();
  await diamondInit.deployed();

  console.log("DiamondInit deployed:", diamondInit.address);

  return {
    diamondInit,
    diamond,
    diamondCutFacet,
    registerDiamondCutFacet,
    diamondLoupeFacet,
    diamondLauncherFacet,
  };
}

export function getFacetIdStringFromName(facetName: string): string {
  const xx = keccak256(Buffer.from(`101.global.${facetName}`));
  const processed = Uint8Array.from(Buffer.from(xx.slice(2), "hex")).slice(
    0,
    20
  );
  return `0x${Buffer.from(processed).toString("hex")}`;
}

export function getFacetIdFromName(facetName: string): Uint8Array {
  const xx = keccak256(Buffer.from(`101.global.${facetName}`));
  return Uint8Array.from(Buffer.from(xx.slice(2), "hex")).slice(0, 20);
}
// Deploy Facets with facet contract names
export async function deployFacets(
  facetContractNames: FacetContractNames
): Promise<FacetContracts> {
  const facetContracts: any = {};
  /* await Promise.all(facetContractNames.map(async (facetName)=>{
    console.log(`${facetName} deploying`)
    const Facet = await ethers.getContractFactory(facetName)
    const facet = await Facet.deploy()
    await facet.deployTransaction.wait(2);
    facetContracts[facetName] = facet; 
    console.log(`${facetName} deployed: ${facet.address}`)
  }))*/
  for (const facetName of facetContractNames) {
    console.log(`${facetName} deploying`);
    const Facet = await ethers.getContractFactory(facetName);
    const facet = await Facet.deploy();
    await facet.deployed();
    facetContracts[facetName] = facet;
    console.log(`${facetName} deployed: ${facet.address}`);
  }
  return facetContracts;
}

// Cut a diamond with specified facets
export async function simpleDiamondCut(
  diamondAddr: string,
  diamondInitAddr: string,
  cuts: Cut[]
) {
  const diamondCut = await ethers.getContractAt("IDiamondCut", diamondAddr);
  const DiamondInit = await ethers.getContractFactory("DiamondInit");
  const functionCall = DiamondInit.interface.encodeFunctionData("init");
  // Cut the Diamond

  const tx = await diamondCut.diamondCut(cuts, diamondInitAddr, functionCall);
  const receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }
}

// Cut a diamond with specified facets
export async function simpleDiamondCutRegister(
  diamondAddr: string,
  diamondInitAddr: string,
  cuts: RegisterCut[]
) {
  const diamondCut = await ethers.getContractAt(
    "IRegisterDiamondCut",
    diamondAddr
  );
  const DiamondInit = await ethers.getContractFactory("DiamondInit");
  const functionCall = DiamondInit.interface.encodeFunctionData("init");
  // Cut the Diamond

  const tx = await diamondCut.diamondCutRegister(
    cuts,
    diamondInitAddr,
    functionCall
  );
  const receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }
}

// Cut a diamond with specified facets
export async function cutDiamond(core: DiamondCoreDeployed, cuts: Cut[]) {
  return simpleDiamondCut(core.diamond.address, core.diamondInit.address, cuts);
}

// Cut a diamond with specified facets
export async function cutDiamondRegister(
  core: DiamondCoreDeployed,
  cuts: RegisterCut[]
) {
  return simpleDiamondCutRegister(
    core.diamond.address,
    core.diamondInit.address,
    cuts
  );
}

// Get facets with a name key
export function getCuts(facets: FacetContracts): FacetCut[] {
  const cuts: FacetCut[] = Object.keys(facets).map((key) => ({
    name: key,
    cut: {
      facetAddress: facets[key].address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facets[key]),
    },
  }));
  return cuts;
}
// Get facets with a name key
export function getCutsWithAddr(facets: {name:string, contract: Contract, address: string}[]): FacetCut[] {
  const cuts: FacetCut[] = facets.map((f) => ({
    name: f.name,
    cut: {
      facetAddress: f.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(f.contract),
    },
  }));
  return cuts;
}

// find a particular address position in the return value of diamondLoupeFacet.facets()
export function findAddressPositionInFacets(
  facetAddress: string,
  facets: Cut[]
) {
  for (let i = 0; i < facets.length; i++) {
    if (facets[i].facetAddress === facetAddress) {
      return i;
    }
  }
}
