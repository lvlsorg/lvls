import { ethers } from "ethers";
import { EventFragment } from "ethers/lib/utils";
interface Launch {
  contract: string;
  owner: string;
}

import { ILvlsContractLauncher } from "lvls-contract";

export function getEventFromLogs(
  lvlsLauncherFacet: ILvlsContractLauncher,
  logs: ethers.providers.Log[]
): Launch {
  const eventDesc =
    lvlsLauncherFacet.interface.events["Launch(address,address)"];
  const result = getSingleEventFromTxLog(
    eventDesc,
    logs,
    lvlsLauncherFacet.interface
  );
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { addr, owner } = result.args as any;
  return { contract: addr, owner };
}

export function getLaunchLvlsEventFromLogs(
  lvlsLauncherFacet: ILvlsContractLauncher,
  logs: ethers.providers.Log[]
): Launch {
  const eventDesc =
    lvlsLauncherFacet.interface.events["Launch(address,address)"];
  const result = getSingleEventFromTxLog(
    eventDesc,
    logs,
    lvlsLauncherFacet.interface
  );
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { addr, owner } = result.args as any;
  return { contract: addr, owner };
}

export function getSingleEventFromTxLog(
  event: EventFragment,
  logs: ethers.providers.Log[],
  abiInterface: ethers.utils.Interface
): ethers.utils.LogDescription {
  for (const log of logs) {
    try {
      const logDesc = abiInterface.parseLog(log);
      if (event.name === logDesc.name) {
        return logDesc;
      }
      // eslint-disable-next-line no-empty
    } catch (e) {}
  }
  throw new Error("Could not find event");
}
