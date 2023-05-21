import fs from "fs-extra";

const REGISTER_CONFIG_PATH = "./src/generated/registerFacets.json";
export const FORGE_REGISTER_CONFIG_PATH =
  "./src/generated/registerFacetsForge.json";
export const FORGE_REQUIREMENTS_CONFIG_PATH =
  "./src/generated/forgeRequirements.json";

export interface ForgeRequirements {
  launcher: string[];
  global: string[];
  localGlobal: string[];
  registry: string[];
}

const OUTPUT_PATH = __dirname + "/../test/foundry/TestFacetLookup.t.sol";

const writePreamble = () => {
  const { global } = readRegisterCuts();
  const globalImports = global
    .map(
      (facet) => `import {${facet}} from "../../contracts/facets/${facet}.sol";`
    )
    .join("\n");

  return `
// This is generated code that is used to have sane lookups for facets on 
// diamond testing run hardhat/scripts/forge.ts to generate more
// it currently defaults to using the production config for facets registered
// use this via contract:local-deploy2 scripts to read consumable facet data
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";

// import all facets so we can instantiate them for testing if needed
${globalImports}

struct FacetCutInfo {
  bytes20 id;
  bytes4[] functionSelectors;
}
contract TestFacetLookup {
  mapping(bytes20 => FacetCutInfo) public facetLookup;
  mapping(string => FacetCutInfo) public facetNameLookup;

  constructor() {
  `;
};

const readRegisterCuts = () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return fs.readJSONSync(FORGE_REQUIREMENTS_CONFIG_PATH) as ForgeRequirements;
};

const writeClose = () => {

  return `
  }

  function makeCut(address facetAddress, FacetCutInfo memory fci) public returns (IDiamondCut.FacetCut memory) {
      IDiamondCut.FacetCut memory fc;
      fc.action = IDiamondCut.FacetCutAction.Add;
      fc.facetAddress = facetAddress;
      fc.functionSelectors = fci.functionSelectors;
      return fc;
  }

  function makeCuts(string[] memory facetNames, address[] memory facetAddress) internal returns (IDiamondCut.FacetCut[] memory cuts) {
    cuts = new IDiamondCut.FacetCut[](facetNames.length);
    for (uint256 i = 0; i < facetNames.length; i++) {
      FacetCutInfo memory fci = facetNameLookup[facetNames[i]];
      cuts[i] = makeCut(facetAddress[i], fci);
    }
  }

  function makeCuts(bytes20[] memory facetIds, address[] memory facetAddress) internal returns (IDiamondCut.FacetCut[] memory cuts) {
    cuts = new IDiamondCut.FacetCut[](facetIds.length);
    for (uint256 i = 0; i < facetIds.length; i++) {
      FacetCutInfo memory fci = facetLookup[facetIds[i]];
      cuts[i] = makeCut(facetAddress[i], fci);
    }
  }
}
`;
};

async function process() {
  let count = 0;
  function translateEntryToSolidity(entry: {
    name: string;
    id: string;
    functionSelectors: string[];
  }): string {
    count += 1;
    const { name, id, functionSelectors } = entry;
    const line1 = `    bytes4[] memory functionSelectors${count} = new bytes4[](${functionSelectors.length});`;
    const line1x = functionSelectors
      .map((s, i) => `    functionSelectors${count}[${i}] = ${s};`)
      .join("\n");
    const line2 = `    bytes20 id${count} = hex"${id.slice(2)}";`;
    const line3 = `    facetLookup[id${count}] = FacetCutInfo({id: id${count}, functionSelectors: functionSelectors${count}});`;
    const line4 = `    facetNameLookup[\"${name}\"] = FacetCutInfo({id: id${count}, functionSelectors: functionSelectors${count}});`;
    return [line1, line1x, line2, line3, line4].join("\n");
  }
  try {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const data = fs.readJSONSync(FORGE_REGISTER_CONFIG_PATH) as any;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const body = Object.entries(data)
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .map(([, v]) => translateEntryToSolidity(v as any))
      .join("\n");
    const result = writePreamble() + body + writeClose();

    fs.writeFileSync(OUTPUT_PATH, result);
  } catch (e) {
    console.log("boookgers");
    console.log(e);
  }
}
if (require.main === module) {
  process();
}
