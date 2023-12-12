import { interpret } from "xstate";
import { lvlsLaunchMachineServices } from "./controllers/lvlsLaunchMachine";
import { createFormMachine } from "./controllers/formMachine";

export const lvlsLaunchController = interpret(
  createFormMachine("lvls-launch", lvlsLaunchMachineServices)
).start();
