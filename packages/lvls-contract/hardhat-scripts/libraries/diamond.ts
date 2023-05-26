/* global ethers */

import { JsonFragment } from "@ethersproject/abi";
import { Contract } from "ethers";
declare global {
  const ethers: any;
}
export function getSignatureWithSelector(contract: Contract) {
  const sigMap = {} as Record<string,any>;
  const signatures = Object.keys(contract.interface.functions);
  signatures.forEach((sig) => {
    sigMap[contract.interface.getSighash(sig)] = sig;
  });
  return sigMap;
}

// get function selectors from ABI
export function getSelectors(contract: Contract): string[] {
  const signatures = Object.keys(contract.interface.functions);
  const selectors = signatures.reduce((acc: any, val: any) => {
    if (val === "supportsInterface(bytes4)") {
      return acc;
    }
    if (val !== "init(bytes)") {
      acc.push(contract.interface.getSighash(val));
    }
    return acc;
  }, []);
  return selectors;
}

export function rmSelectors(
  contract: Contract,
  functionNames: string,
  selectors: string[]
) {
  return selectors.filter((v) => {
    for (const functionName of functionNames) {
      if (v === contract.interface.getSighash(functionName)) {
        return false;
      }
    }
    return true;
  });
}

export function getSelectorsFromName(
  contract: Contract,
  functionNames: string[],
  selectors: string[]
): string[] {
  return selectors.filter((v) => {
    for (const functionName of functionNames) {
      if (v === contract.interface.getSighash(functionName)) {
        return true;
      }
    }
    return false;
  });
}

// get function selector from function signature
export function getSelector(func: JsonFragment): string {
  const abiInterface = new ethers.utils.Interface([func]);
  return abiInterface.getSighash(ethers.utils.Fragment.from(func));
}

// remove selectors using an array of signatures
export function removeSelectorsWithSignatures(
  selectors: string[],
  signatures: string[]
) {
  const iface = new ethers.utils.Interface(
    signatures.map((v) => "function " + v)
  );
  const removeSelectors = signatures.map((v) => iface.getSighash(v));
  selectors = selectors.filter((v) => !removeSelectors.includes(v));
  return selectors;
}
