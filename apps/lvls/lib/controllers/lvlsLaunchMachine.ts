import { FormServices, ContextType, skip } from "./formMachine";
import { ethers } from "ethers";
import config from "../../../../packages/lvls-contract/src/generated/launcher.json";
export enum Stages {
  lvlLaunch = "lvlLaunch"
}
import {
  ILvlsContractLauncher__factory,
  ISoulboundDecayStaking__factory
} from "lvls-contract";
import { getLaunchLvlsEventFromLogs } from "../utils";

interface Context extends ContextType {
  owner?: string;
  stage?: string;
  exchangeRate?: string;
  penaltyRate?: string;
  lvlsAddress?: string;
  xpTokenAddress?: string;
  lxpTokenAddress?: string;
  rewardTokenAddress?: string;
  signer?: ethers.Signer;
}

export const lvlsLaunchMachineServices: FormServices<Context> = {
  phase1: () => async (context: Context) => {
    if (window.ethereum === undefined)
      throw new Error("window.ethereum is undefined");
    const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = provider.getSigner();

    return {
      ...context,
      signer
    };
  },
  phase2: () => async (context: Context) => {
    let xpTokenAddress = "";
    let lvlsAddress = "";
    console.log("outside the the stage", context);
    if (context.signer === undefined) throw new Error("signer is undefined");
    if (context.owner === undefined) throw new Error("owner is undefined");
    console.log("made it here");
    if (context.stage === Stages.lvlLaunch) {
      console.log("Inside the stage");
      const chainId = await context.signer.getChainId();
      console.log(chainId);
      const lvlsLauncherFacet = await ILvlsContractLauncher__factory.connect(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (config as any)[chainId]?.Diamond,
        context.signer
      );

      try {
        const tx = await (await lvlsLauncherFacet.launch(context.owner)).wait();
        const result = await getLaunchLvlsEventFromLogs(
          lvlsLauncherFacet,
          tx.logs
        );
        lvlsAddress = result.contract;
        const lvls = ISoulboundDecayStaking__factory.connect(
          result.contract,
          context.signer
        );
        xpTokenAddress = (await lvls.xpTokenAddress()) || "";
      } catch (e) {
        console.log("error:", e);
      }
    }
    return {
      ...context,
      xpTokenAddress,
      lvlsAddress
    };
  },
  phase3: skip
};
