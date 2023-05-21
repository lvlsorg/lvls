/* eslint prefer-const: "off" */

// require("@nomicfoundation/hardhat-toolbox");

import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import type * as nhEthers from "ethers";

import fs from "fs-extra";
import Launcher from "../src/artifacts/contracts/facets/DiamondContractLauncherFacet.sol/DiamondContractLauncherFacet.json";
import {
  getFacetIdStringFromName,
  getCutsWithAddr,
  simpleDiamondCut,
  simpleDiamondCutRegister,
  setDeploymentConfigFacets
} from "./libraries/diamondUtils";
import { getFacetIdFromName } from "./libraries/diamondUtils";
import { getSignatureWithSelector } from "./libraries/diamond";

import { ForgeRequirements } from "./forge";

export const TEST_CONFIG_DEFAULT_PATH = "./test/generated/deployed.json";
export const TEST_GLOBAL_CONFIG_PATH = "./test/generated/globalDepoyed.json";
export const REGISTER_TEST_CONFIG_PATH = "./test/generated/registerFacet.json";
export const FORGE_REGISTER_TEST_CONFIG_PATH =
  "./test/generated/registerFacetsForge.json";
export const FORGE_REQUIREMENTS_TEST_CONFIG_PATH =
  "./test/src/generated/forgeRequirements.json";

const CONFIG_DEFAULT_PATH = "./src/generated/deployed.json";
const GLOBAL_CONFIG_PATH = "./src/generated/globalDeployed.json";
const REGISTER_CONFIG_PATH = "./src/generated/registerFacets.json";
export const FORGE_REGISTER_CONFIG_PATH =
  "./src/generated/registerFacetsForge.json";
export const FORGE_REQUIREMENTS_CONFIG_PATH =
  "./src/generated/forgeRequirements.json";

export const LOGGER_CONFIG_PATH = "./src/generated";

interface Fees {
  [key: string]: {
    multiplier: number;
    minFee: string;
    maxFee: string;
  };
}

const launcherAbi = Launcher.abi;
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
  "RegisterDiamondCutFacet",
  "DiamondLoupeFacet",
  "DiamondLauncherFacet",
  "DiamondInit",
  "DiamondContractLauncherFacet",
  "OwnershipFacet",
  "ERC725YFacet",
  "Metadata",
  "MulticallFacet",
  "ClaimsFacet",
  "RoyaltyFacet",
  "OurDelegatableFacet",
  "ERC721TokenBaseFacet"
];

const nftFacetContractNames: FacetName[] = [
  "ERC721TokenBaseFacet",
  "OwnershipFacet",
  "DiamondLoupeFacet",
  "Metadata",
  "MulticallFacet",
  "ERC725YFacet",
  "ClaimsFacet",
  "RoyaltyFacet",
  "OurDelegatableFacet",
  "RegisterDiamondCutFacet"
];

const launcherFacetContractNames: FacetName[] = [
  "DiamondContractLauncherFacet",
  "DiamondLauncherFacet",
  "OwnershipFacet",
  "DiamondLoupeFacet",
  "ERC725YFacet"
];

const runListDiamondSteps = [
  "deployDiamondLauncher",
  "cutDiamondLauncher",
  "generateForgeData",
  "deployGlobalDiamondRegistry",
  "cutGlobalDiamondRegistry",
  "saveConfig",
  "setLauncherDiamondAttrs",
  "updateFacetData"
];

const alwaysRunDiamondSteps: typeof runListDiamondSteps[number][] = [
  "generateForgeData"
];

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
  const RunContractMapping = await makeRunContractMapping();
  const signer = await ethers.getSigners()[0];

  interface DiamondRunItem {
    stepName: typeof runListDiamondSteps[number];
    address?: string;
  }

  interface FacetRunItem {
    contractName: keyof typeof RunContractMapping;
    address?: string;
  }
  type DiamondRunList = DiamondRunItem[];
  type FacetRunList = FacetRunItem[];
  const expectedFacetRunList: FacetRunList = runListFacetContractNames.map(
    (contractName) => ({ contractName })
  );

  const expectedDiamondRunList: DiamondRunList = runListDiamondSteps.map(
    (stepName) => ({
      stepName
    })
  );
  interface RunLog {
    facetRunList: FacetRunList;
    diamondRunList: DiamondRunList;
  }
  const getRunLog = async (): Promise<RunLog> => {
    const chainId = await (await ethers.getSigners())[0].getChainId();
    try {
      fs.ensureFileSync(`${LOGGER_CONFIG_PATH}/run_log_${chainId}.json`);
      const data =
        fs.readFileSync(`${LOGGER_CONFIG_PATH}/run_log_${chainId}.json`) ||
        `{"diamondRunList": [], "facetRunList": []}`;
      return JSON.parse(data.toString()) as unknown as RunLog;
    } catch (e) {
      console.log("No run log found, creating new memory one");
      return { diamondRunList: [], facetRunList: [] };
    }
  };

  const writeRunLog = async (facetRunList: FacetRunList, diamondRunList) => {
    const chainId = await (await ethers.getSigners())[0].getChainId();
    return fs.writeFileSync(
      `${LOGGER_CONFIG_PATH}/run_log_${chainId}.json`,
      JSON.stringify({ facetRunList, diamondRunList }, null, 2)
    );
  };

  const lastRun = await getRunLog();
  console.log(lastRun);
  const currentFacetRunList: FacetRunList = [];
  const currentDiamondRunList: DiamondRunList = [];
  // To make it easier to look up previous step values
  const currentDiamondRunMap = {} as {
    [key: typeof runListDiamondSteps[number]]: DiamondRunItem;
  };

  const lastFacetRunMap = lastRun.facetRunList.reduce((acc, item) => {
    acc[item.contractName] = item;
    return acc;
  }, {} as { [key: string]: FacetRunItem });
  try {
    for (const item of expectedFacetRunList) {
      currentFacetRunList.push(item);
      if (
        !lastFacetRunMap[item.contractName] ||
        !lastFacetRunMap[item.contractName].address
      ) {
        // deploy it
        console.log(
          "heeree",
          item.contractName,
          (
            await RunContractMapping[
              item.contractName
            ].signer.provider?.getBlockNumber()
          )?.toString()
        );
        currentFacetRunList[currentFacetRunList.length - 1].address = (
          await RunContractMapping[item.contractName].deploy()
        ).address;
      } else {
        currentFacetRunList[currentFacetRunList.length - 1].address =
          lastFacetRunMap[item.contractName].address;
      }
    }
    const currentFacetRunMap = currentFacetRunList.reduce((acc, item) => {
      acc[item.contractName] = item;
      return acc;
    }, {} as { [key: FacetName]: FacetRunItem });

    const getFacetData = (
      facetNames: FacetName[]
    ): { name: string; address: string; contract: nhEthers.Contract }[] => {
      return facetNames.map((contractName) => {
        console.log(contractName);
        const { address } = currentFacetRunMap[contractName];
        if (!address) throw new Error(`No address for ${contractName}`);
        return {
          name: contractName,
          address,
          contract: RunContractMapping[contractName].attach(address)
        };
      });
    };

    type DiamondStepName = typeof runListDiamondSteps[number];

    const DiamondSteps: Record<
      DiamondStepName,
      () => Promise<string | undefined>
    > = {
      deployDiamondLauncher: async () => {
        //NOTE TODO setting gas limit here
        const accounts = await ethers.getSigners();
        const contractOwner = accounts[0];
        const Diamond = await ethers.getContractFactory("Diamond");
        const diamond = await Diamond.deploy(
          contractOwner.address,
          currentFacetRunMap.DiamondCutFacet.address,
          currentFacetRunMap.RegisterDiamondCutFacet.address,
          currentFacetRunMap.DiamondLoupeFacet.address
        );
        await diamond.deployed();
        return diamond.address;
      },
      cutDiamondLauncher: async () => {
        const launcherFacets = launcherFacetContractNames.map(
          (contractName) => {
            const { address } = currentFacetRunMap[contractName];
            if (!address) throw new Error(`No address for ${contractName}`);
            return {
              name: contractName,
              address,
              contract: RunContractMapping[contractName].attach(address)
            };
          }
        );
        const cuts = getCutsWithAddr(launcherFacets);
        const diamondAddr =
          currentDiamondRunMap["deployDiamondLauncher"].address!;
        const initAddr = currentFacetRunMap.DiamondInit.address!;

        await simpleDiamondCut(
          diamondAddr,
          initAddr,
          cuts.map((c) => c.cut)
        );

        return undefined;
      },
      generateForgeData: async () => {
        forgeReqs["launcher"] = launcherFacetContractNames;
        const nftFacetCuts = getCutsWithAddr(
          getFacetData(nftFacetContractNames)
        );
        const nftLauncherFacetCuts = getCutsWithAddr(
          getFacetData(launcherFacetContractNames)
        );

        console.log("Cutting Global Diamond");
        const registerFacets = nftFacetCuts.map((f) => {
          return {
            facetCut: f.cut,
            id: getFacetIdFromName(f.name)
          };
        });
        const dbgRegisterFacets = await Promise.all(
          nftFacetCuts.map(async (f) => {
            const contract = await ethers.getContractAt(
              f.name,
              f.cut.facetAddress
            );
            return {
              sigMap: getSignatureWithSelector(contract),
              name: f.name,
              facetCut: f.cut,
              id: getFacetIdStringFromName(f.name)
            };
          })
        );
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const forgeResults: any = {};

        const dbgForgeRegisterFacets = await Promise.all(
          nftLauncherFacetCuts.concat(nftFacetCuts).map(async (f) => {
            const forgeSet = {
              functionSelectors: f.cut.functionSelectors,
              id: getFacetIdStringFromName(f.name),
              name: f.name
            };
            forgeResults[f.name] = forgeSet;
            forgeResults[getFacetIdStringFromName(f.name)] = forgeSet;
            return;
          })
        );

        const result = await Promise.all(dbgRegisterFacets);
        await Promise.all(dbgForgeRegisterFacets);
        fs.writeFileSync(
          testEnv ? REGISTER_TEST_CONFIG_PATH : REGISTER_CONFIG_PATH,
          JSON.stringify(result, null, 2)
        );
        // write forge specific formatted dbg results
        fs.writeFileSync(
          testEnv
            ? FORGE_REGISTER_TEST_CONFIG_PATH
            : FORGE_REGISTER_CONFIG_PATH,
          JSON.stringify(forgeResults, null, 2)
        );

        forgeReqs["global"] = nftFacetContractNames;

        forgeReqs["localGlobal"] = [
          "DiamondLoupeFacet",
          "ERC725YFacet",
          "OwnershipFacet"
        ];
        forgeReqs["registry"] = [
          "DiamondLoupeFacet",
          "DiamondCutRegisterFacet",
          "ERC725YFacet",
          "OwnershipFacet"
        ];
        // write forge specific formatted dbg results
        fs.writeFileSync(
          testEnv
            ? FORGE_REQUIREMENTS_TEST_CONFIG_PATH
            : FORGE_REQUIREMENTS_CONFIG_PATH,
          JSON.stringify(forgeReqs, null, 2)
        );

        return undefined;
      },
      deployGlobalDiamondRegistry: async () => {
        const accounts = await ethers.getSigners();
        const contractOwner = accounts[0];
        const Diamond = await ethers.getContractFactory("Diamond");
        const diamond = await Diamond.deploy(
          contractOwner.address,
          currentFacetRunMap.DiamondCutFacet.address,
          currentFacetRunMap.RegisterDiamondCutFacet.address,
          currentFacetRunMap.DiamondLoupeFacet.address
        );
        await diamond.deployed();
        return diamond.address;
      },
      cutGlobalDiamondRegistry: async () => {
        const dbgCuts = getCutsWithAddr(getFacetData(nftFacetContractNames));
        const nftGlobalCuts = await Promise.all(
          dbgCuts.map(async (f) => {
            return {
              facetCut: f.cut,
              id: getFacetIdFromName(f.name)
            };
          })
        );
        await simpleDiamondCutRegister(
          currentDiamondRunMap.deployGlobalDiamondRegistry.address!,
          currentFacetRunMap.DiamondInit.address!,
          nftGlobalCuts
        );
        await simpleDiamondCut(
          currentDiamondRunMap.deployGlobalDiamondRegistry.address!,
          currentFacetRunMap.DiamondInit.address!,
          dbgCuts
            .filter(
              (f) => f.name === "DiamondLoupeFacet" || f.name === "ERC725YFacet"
            )
            .map((f) => f.cut)
        );
        return undefined;
      },
      saveConfig: async () => {
        const configPath = testEnv
          ? TEST_CONFIG_DEFAULT_PATH
          : CONFIG_DEFAULT_PATH;
        const globalConfigPath = testEnv
          ? TEST_GLOBAL_CONFIG_PATH
          : GLOBAL_CONFIG_PATH;
        const chainId = await (await ethers.getSigners())[0].getChainId();

        const launcherDeployedMap = {
          Diamond: currentDiamondRunMap.deployDiamondLauncher.address!,
          DiamondCutFacet: currentFacetRunMap.DiamondCutFacet.address!,
          DiamondLoupeFacet: currentFacetRunMap.DiamondLoupeFacet.address!,
          DiamondInitFacet: currentFacetRunMap.DiamondInit.address!,
          DiamondLauncherFacet: currentFacetRunMap.DiamondLauncherFacet.address!
        };
        const launcherFacetCuts = getCutsWithAddr(
          getFacetData(launcherFacetContractNames)
        );
        const globalDeployedMap = {
          Diamond: currentDiamondRunMap.deployGlobalDiamondRegistry.address!,
          DiamondCutFacet: currentFacetRunMap.DiamondCutFacet.address!,
          DiamondLoupeFacet: currentFacetRunMap.DiamondLoupeFacet.address!,
          DiamondInitFacet: currentFacetRunMap.DiamondInit.address!,
          DiamondLauncherFacet: currentFacetRunMap.DiamondLauncherFacet.address!
        };
        const globalFacetCuts = getCutsWithAddr(
          getFacetData(nftFacetContractNames)
        );
        await setDeploymentConfigFacets(
          configPath,
          chainId,
          launcherDeployedMap,
          launcherFacetCuts
        );
        await setDeploymentConfigFacets(
          globalConfigPath,
          chainId,
          globalDeployedMap,
          globalFacetCuts
        );

        return undefined;
      },
      setLauncherDiamondAttrs: async () => {
        const chainId = await (await ethers.getSigners())[0].getChainId();
        const launcher = RunContractMapping.DiamondContractLauncherFacet.attach(
          currentDiamondRunMap.deployDiamondLauncher.address!
        );
        const globalDiamondRegistry =
          currentDiamondRunMap.deployGlobalDiamondRegistry.address!;
        // NOTE TODO this is gotta be chain specific
        await (
          await launcher.setLauncherGlobalDiamondProxy([
            { namespace: true, diamondAddress: globalDiamondRegistry }
          ])
        ).wait();

        await (
          await launcher.setDiamondAddresses(
            currentFacetRunMap.DiamondCutFacet.address!,
            currentFacetRunMap.RegisterDiamondCutFacet.address!,
            currentFacetRunMap.DiamondLoupeFacet.address!,
            currentFacetRunMap.DiamondInit.address!
          )
        ).wait();

        return undefined;
      },
      updateFacetData: async () => {
        const globalCuts = getCutsWithAddr(getFacetData(nftFacetContractNames));
        const globalDiamondRegistry =
          currentDiamondRunMap.deployGlobalDiamondRegistry.address!;
        const dbgGlobalCuts = await Promise.all(
          globalCuts.map(async (f) => {
            const contract = await ethers.getContractAt(
              f.name,
              f.cut.facetAddress
            );
            console.log("Contract: ", f.name, contract.address),
              getFacetIdStringFromName(f.name);
            return {
              name: f.name,
              id: getFacetIdStringFromName(f.name)
            };
          })
        );

        const erc725 = RunContractMapping.ERC725YFacet.attach(
          globalDiamondRegistry!
        );

        const facetAddress = globalCuts.map((f) => f.cut.facetAddress);
       return undefined;
      }
    };
    // NOTE technically a sequential borderline
    const lastDiamondRunMap = lastRun.diamondRunList.reduce((acc, item) => {
      acc[item.stepName] = item;
      return acc;
    }, {} as { [key: typeof runListDiamondSteps[number]]: DiamondRunItem });
    for (const step of runListDiamondSteps) {
      console.log("Running: ", step);

      if (!lastDiamondRunMap[step] || alwaysRunDiamondSteps.includes(step)) {
        const address = await DiamondSteps[step]();
        currentDiamondRunList.push({ stepName: step, address });
      } else {
        currentDiamondRunList.push({
          stepName: step,
          address: lastDiamondRunMap[step].address
        });
      }
      currentDiamondRunMap[step] =
        currentDiamondRunList[currentDiamondRunList.length - 1];
    }
  } catch (e) {
    console.log("Error deploying facets, writing run log");
    throw e;
  } finally {
    await writeRunLog(currentFacetRunList, currentDiamondRunList);
  }
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployFacets()
    .then(() => process.exit(0))
    .catch((error) => {
      console.log(error.stack);
      console.error(error);
      process.exit(1);
    });
}

exports.deployDiamond = deployFacets;
