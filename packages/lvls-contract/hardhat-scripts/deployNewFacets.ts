/* eslint prefer-const: "off" */

// require("@nomicfoundation/hardhat-toolbox");

import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import { keccak256 } from "ethers/lib/utils";
import type * as nhEthers from "ethers";
import path from "path";

import fs from "fs-extra";
// import Launcher from "../src/artifacts/contracts/facets/DiamondContractLauncherFacet.sol/DiamondContractLauncherFacet.json";
import {
  FacetConfigs,
  FacetCut,
  getCutsWithAddr,
  getDeploymentConfig
} from "./libraries/diamondUtils";
import { getSignatureWithSelector } from "./libraries/diamond";

import { ForgeRequirements } from "./forge";
import { chain } from "lodash";

export const CONFIG_DEFAULT_PATH="./src/generated/deployed.json";
export const TEST_CONFIG_DEFAULT_PATH = "./test/generated/deployed.json";
export const TEST_GLOBAL_CONFIG_PATH = "./test/generated/globalDepoyed.json";
export const REGISTER_TEST_CONFIG_PATH = "./test/generated/registerFacet.json";
export const FORGE_REGISTER_TEST_CONFIG_PATH =
  "./test/generated/registerFacetsForge.json";
export const FORGE_REQUIREMENTS_TEST_CONFIG_PATH =
  "./test/src/generated/forgeRequirements.json";

export const FORGE_REGISTER_CONFIG_PATH =
  "./src/generated/registerFacetsForge.json";
export const FORGE_REQUIREMENTS_CONFIG_PATH =
  "./src/generated/forgeRequirements.json";

export const LOGGER_CONFIG_PATH = "./src/generated";

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
      ((facetConfigs as any)[facetCut.name] = facetCut.cut)
  );
  config[chainId] = facetConfigs;
  await fs.promises.writeFile(
    path.resolve(configPath),
    JSON.stringify(config, null, 2)
  );
}
const forgeReqs: ForgeRequirements = {} as ForgeRequirements;

// first thing we do is read last_run.log
// for every face it will include a name and contract address
// we create a lits of all the facets we have to deploy
// we create a map of the context they are in
// we run through the list that directly maps name to contract
// this is an ordered list so we know the order to deploy them in
// at start we run through the list and find the first missing entry
// we then deploy that entry and add it to the list
// once all facets are deployed we can then deploy the diamonds

type FacetName = typeof runListFacetContractNames[number];

const runListFacetContractNames = [
  "DiamondCutFacet",
  "DiamondLoupeFacet",
  "OwnershipFacet",
  "ERC725YFacet",
  "LSP7DigitalAssetFacet",
  "XPLSP7TokenFacet",
  "LXPFacet",
  "SoulboundDecayStakingFacet"
];

export function getFacetIdStringFromName(facetName: string): string {
  const xx = keccak256(Buffer.from(`${facetName}`));
  const processed = Uint8Array.from(Buffer.from(xx.slice(2), "hex")).slice(
    0,
    20
  );
  return `0x${Buffer.from(processed).toString("hex")}`;
}

const makeRunContractMapping = async () => {
  const contractMapping = {} as any;
  const signer = await ethers.getSigners()[0];
  for (const contractName of runListFacetContractNames) {
    contractMapping[contractName] = await ethers.getContractFactory(
      contractName,
      signer
    );
  }
  return contractMapping as { [key: string]: nhEthers.ContractFactory };
};

const deployFacets = async (testEnv = false) => {
  const contractMapping = await makeRunContractMapping();
  const signer = await ethers.getSigner();
  const chainId = await signer.getChainId();
  const contractFacetData=[]; 
  forgeReqs["global"] = runListFacetContractNames;
        fs.writeFileSync(
             FORGE_REQUIREMENTS_CONFIG_PATH,
          JSON.stringify(forgeReqs, null, 2)
        );
  for(const contractName of runListFacetContractNames) {
    const contract = await ethers.getContractFactory(
      contractName,
      signer
    );
    const facet = await contract.deploy();
    const addr = facet.address;
    await facet.deployed();
    contractFacetData.push({
      name: contractName,
      address: addr,
      contract
    });
  }
  const dbgFacetInfo = contractFacetData.map((f)=> {
    return {
      sigMap: getSignatureWithSelector(f.contract),
      name: f.name,
      facetCut: getCutsWithAddr([f])[0].cut,
      id: getFacetIdStringFromName(f.name)
    }
  })
  await setDeploymentConfigFacets(CONFIG_DEFAULT_PATH,chainId,{}, dbgFacetInfo.map((f)=>({name: f.name, cut: f.facetCut})))
        const forgeResults: any = {};
  dbgFacetInfo.map((f)=> {
   const forgeSet = {
              functionSelectors: f.facetCut.functionSelectors,
              id: getFacetIdStringFromName(f.name),
              name: f.name
            };
            forgeResults[f.name] = forgeSet;
            forgeResults[getFacetIdStringFromName(f.name)] = forgeSet;
          })
        // write forge specific formatted dbg results
        fs.writeFileSync(
             FORGE_REGISTER_CONFIG_PATH,
          JSON.stringify(forgeResults, null, 2)
        );
}

deployFacets();

