/* eslint-disable @typescript-eslint/no-unused-vars */
import {
  ActorRefFrom,
  StateFrom,
  createMachine,
  assign,
  NoInfer,
  Interpreter,
  ResolveTypegenMeta,
  TypegenDisabled,
  BaseActionObject,
  ServiceMap
} from "xstate";

// import { MetamaskMachine, blockUntilReady } from "./MetamaskMachine";
/*
declare global {
  interface Window {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ethereum: any;
  }
}*/

export enum BaseStates {
  initial = "initial",
  acceptFormData = "acceptFormData",
  phase1 = "phase1",
  phase1End = "phase1End",
  phase2 = "phase2",
  phase2End = "phase2End",
  phase3 = "phase3",
  complete = "complete",
  failure = "failure"
}

export enum BaseEvent {
  setFormData = "setFormData",
  phase1Start = "phase1Start",
  phase2Start = "phase2Start",
  phase3Start = "phase3Start",
  finished = "finished",
  reset = "reset",
  complete = "complete",
  error = "error"
}

export interface BaseEventData<T> {
  data: Partial<T>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  error?: ErrorWithTransition;
}
// Allows you to terminate the session successfully before
// all the phases have completed
export interface CompleteEvent<T> extends BaseEventData<T> {
  type: BaseEvent.complete;
}

export interface SetFormData<T> extends BaseEventData<T> {
  type: BaseEvent.setFormData;
}

export interface Phase1Start<T> extends BaseEventData<T> {
  type: BaseEvent.phase1Start;
}

export interface Phase2Start<T> extends BaseEventData<T> {
  type: BaseEvent.phase2Start;
}

export interface Phase3Start<T> extends BaseEventData<T> {
  type: BaseEvent.phase3Start;
}

export interface ResetEvent<T> extends BaseEventData<T> {
  type: BaseEvent.reset;
}

export interface FinishedEvent<T> extends BaseEventData<T> {
  type: BaseEvent.finished;
}

export interface ErrorEvent<T> extends BaseEventData<T> {
  type: BaseEvent.error;
}

export type ContextType = Record<string, unknown>;

export type BaseState<TContext extends ContextType> = {
  value: BaseStates;
  context: TContext;
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const skip: FormService<any> = () => async (context) => {
  return { ...context };
};

export type Events<T extends ContextType> =
  | SetFormData<T>
  | ResetEvent<T>
  | FinishedEvent<T>
  | Phase1Start<T>
  | Phase2Start<T>
  | Phase3Start<T>
  | CompleteEvent<T>
  | ErrorEvent<T>;

const makeInvoker = <TContext extends ContextType>(
  phase: string,
  error: BaseStates,
  target: BaseStates
) => {
  return {
    invoke: {
      id: `${phase}-id`,
      src: phase,
      onError: {
        target: error,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        actions: assign((context: NoInfer<TContext>, event: any) => {
          return {
            ...context,
            error: event.error || { error: event.data }
          };
        })
      },
      onDone: {
        target: target,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        actions: assign((context: NoInfer<TContext>, event: any) => {
          return {
            ...context,
            ...event.data
          };
        })
      }
    }
  };
};

export interface ErrorWithTransition {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  error?: any;
  transition: BaseEvent;
}

export interface FormService<TContext extends ContextType> {
  (): (
    context: TContext,
    event: Events<TContext>
  ) => Promise<Partial<TContext>>;
}

export interface FormServices<TContext extends ContextType> {
  phase1: FormService<TContext>;
  phase2: FormService<TContext>;
  phase3: FormService<TContext>;
}

export const createFormMachine = <TContext extends ContextType, T>(
  formId: string,
  formServices: FormServices<TContext>
) => {
  const initialContext: TContext = {} as Record<string, unknown> as TContext;
  const logFullCopyError = (stateName: string) => {
    return (context: TContext, event: Events<TContext>) => {
      console.log(stateName, context, event);
      return {
        ...context,
        error: undefined
      };
    };
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const logFullCopy = (stateName: string) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return (context: TContext, event: any) => {
      console.log(stateName, context, event);
      return fullCopy(context, event);
    };
  };
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const fullCopy = (context: TContext, event: any) => {
    return {
      ...context,
      ...event.data
    };
  };
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const services = {} as any;
  Object.entries(formServices).forEach(([key, value]) => {
    services[key] = value();
  });
  return createMachine<TContext, Events<TContext>, BaseState<TContext>>(
    {
      predictableActionArguments: true,
      id: formId,
      initial: BaseStates.initial,
      context: initialContext,
      states: {
        [BaseStates.initial]: {
          on: {
            [BaseEvent.setFormData]: {
              target: BaseStates.initial,
              actions: assign(logFullCopy("initial"))
            },
            [BaseEvent.phase1Start]: {
              target: BaseStates.phase1,
              actions: assign(logFullCopy("initial"))
            }
          }
        },
        [BaseStates.phase1]: {
          ...makeInvoker<TContext>(
            "phase1",
            BaseStates.failure,
            BaseStates.phase1End
          )
        },
        [BaseStates.phase1End]: {
          on: {
            [BaseEvent.setFormData]: {
              target: BaseStates.phase1End,
              actions: assign(logFullCopy("phase1End"))
            },
            [BaseEvent.phase2Start]: {
              target: BaseStates.phase2,
              actions: assign(logFullCopy("phase1End"))
            }
          }
        },
        [BaseStates.phase2]: {
          ...makeInvoker<TContext>(
            "phase2",
            BaseStates.failure,
            BaseStates.phase2End
          )
        },
        [BaseStates.phase2End]: {
          on: {
            [BaseEvent.setFormData]: {
              target: BaseStates.phase1End,
              actions: assign(logFullCopy("phase2end"))
            },
            [BaseEvent.phase2Start]: {
              target: BaseStates.phase2,
              actions: assign(logFullCopy("phase2end"))
            },
            [BaseEvent.phase3Start]: {
              target: BaseStates.phase3,
              actions: assign(logFullCopy("phase2end"))
            }
          }
        },
        [BaseStates.phase3]: {
          ...makeInvoker<TContext>(
            "phase3",
            BaseStates.failure,
            BaseStates.complete
          )
        },
        [BaseStates.complete]: {
          on: {
            [BaseEvent.reset]: {
              target: BaseStates.initial
            },
            // here we'll reset the state to original form
            [BaseEvent.finished]: {
              target: BaseStates.initial,
              actions: assign((t, _event) => {
                // console.log("clearing and resetting on completion", _event);
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                const clearContext = {} as any;
                Object.keys(t).forEach((key) => {
                  clearContext[key] = undefined;
                });
                return { ...clearContext };
              })
            }
          }
        },
        [BaseStates.failure]: {
          on: {
            [BaseEvent.phase1Start]: {
              target: BaseStates.phase1,
              actions: assign((t, e) => ({ ...t, error: undefined }))
            },
            [BaseEvent.phase2Start]: {
              target: BaseStates.phase2,
              actions: assign((t, e) => ({ ...t, error: undefined }))
            },
            [BaseEvent.phase3Start]: {
              target: BaseStates.phase3,
              actions: assign((t, e) => ({ ...t, error: undefined }))
            }
          }
        }
      },
      on: {
        [BaseEvent.error]: {
          target: BaseStates.failure,
          actions: assign((t, event) => {
            return {
              ...t,
              error: event.error
            };
          })
        },
        [BaseEvent.complete]: {
          target: BaseStates.complete,
          actions: assign(logFullCopy("complete"))
        },
        [BaseEvent.finished]: BaseStates.initial,
        [BaseEvent.reset]: {
          target: BaseStates.initial,
          actions: assign((t, _event) => {
            //console.log("clearing on a reset state", _event);
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const clearContext = {} as any | Record<string, any>;
            Object.keys(t).forEach((key) => {
              clearContext[key] = undefined;
            });
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            return { ...clearContext } as any;
          })
        }
      }
    },
    { services }
  );
};

export type CreateBaseMachine = ActorRefFrom<
  ReturnType<typeof createFormMachine>
>;
export type CreateBaseMachineState = StateFrom<
  ReturnType<typeof createFormMachine>
>;

export type BaseController<Context extends ContextType> = Interpreter<
  Context,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  any,
  Events<Context>,
  BaseState<Context>,
  ResolveTypegenMeta<
    TypegenDisabled,
    Events<Context>,
    BaseActionObject,
    ServiceMap
  >
>;
