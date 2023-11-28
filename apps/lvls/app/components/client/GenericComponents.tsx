"use client";
/* eslint-disable @next/next/no-img-element */
import { useActor, useSelector } from "@xstate/react";
import classNames from "classnames";
import React, { useEffect, useState } from "react";
import {
  BaseController,
  BaseEvent,
  BaseStates,
  ContextType
} from "../../../lib/controllers/formMachine";

export const genericTextAreaStyle = classNames(
  "block mt-1 p-4 w-full",
  "text-zinc-900 bg-white rounded-lg border",
  "border-zinc-400 sm:text-md focus:ring-blue-500 focus:border-blue-500"
);

export const genericInputStyle = classNames(
  "block mt-1 p-4 w-full",
  "text-zinc-900 bg-white rounded-lg border",
  "border-zinc-400 sm:text-md focus:ring-blue-500 focus:border-blue-500"
);

export const genericInputStyleDisabled = classNames(
  "block mt-1 p-4 w-full",
  "text-zinc-400 bg-zinc-100 rounded-lg border",
  "border-zinc-400 sm:text-md focus:ring-blue-500 focus:border-blue-500"
);

export const blackButtonStyle = classNames(
  "px-5",
  "py-2.5",
  "text-xl",
  "text-center",
  "text-white",
  "cursor-pointer",
  "bg-zinc-900 hover:bg-zinc-800",
  "rounded-lg",
  "font-normal",
  "font-forma"
);

export interface RadioLabel {
  label: string;
  value: string;
}
export interface RadioProps {
  labels: RadioLabel[];
}

export function makeUpdateCheckbox<Context extends ContextType>(
  entryKey: string,
  controller: BaseController<Context>,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  updatePhase = BaseStates.phase1End
) {
  return function Checkbox(
    { disabled }: { disabled?: boolean } = { disabled: false }
  ) {
    const [, send] = useActor(controller);
    const checkState: boolean = useSelector(controller, (s) =>
      s.context[entryKey] ? true : false
    );

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const data = {} as any;
    return (
      <input
        type="checkbox"
        disabled={disabled}
        checked={checkState}
        onChange={(e) => {
          data[entryKey] = e.target.checked;
          send({
            type: BaseEvent.setFormData,
            data
          });
        }}
        className="scale-125"
      />
    );
  };
}
export interface NumberInputParams {
  min?: number;
  max?: number;
  step?: number;
  default: number;
}

export interface DateInputParams {
  min: string;
  max: string;
  default: string;
}

export function makeUpdateInputDate<Context extends ContextType>(
  entryKey: string,
  controller: BaseController<Context>,
  params: DateInputParams,
  updatePhase = BaseStates.phase1End,
  inactiveState: string | undefined = undefined
) {
  return function UpdateDateInput() {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [, send] = useActor(controller);
    const disabled = useSelector(controller, (s) =>
      inactiveState ? (s.context[inactiveState] as boolean) : false
    );
    const isUpdatePhase = useSelector(controller, (s) =>
      s.matches(updatePhase)
    );
    const val = useSelector(controller, (s) =>
      s.context[entryKey] === undefined
        ? params.default
        : (s.context[entryKey] as string)
    );
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const data = {} as any;

    useEffect(() => {
      if (isUpdatePhase) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const data = {} as any;
        data[entryKey] = val;
        send({
          type: BaseEvent.setFormData,
          data
        });
      }
    }, [isUpdatePhase]);

    return (
      <input
        value={val === undefined ? params.default : val}
        onChange={(e) => {
          data[entryKey] = e.target.value;
          send({
            type: BaseEvent.setFormData,
            data
          });
        }}
        min={params.min}
        max={params.max}
        type="datetime-local"
        disabled={disabled}
        className={disabled ? genericInputStyleDisabled : genericInputStyle}
      />
    );
  };
}

export function makeUpdateInputNumber<Context extends ContextType>(
  entryKey: string,
  controller: BaseController<Context>,
  params: NumberInputParams,
  updatePhase = BaseStates.phase1End,
  inactiveState: string | undefined = undefined
) {
  return function UpdateInputNumber() {
    const val = useSelector(controller, (s) => {
      const value =
        s.context[entryKey] === undefined
          ? params.default
          : (s.context[entryKey] as number);
      return value;
    });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [, send] = useActor(controller);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    // const [val, setVal] = useState<any>();

    const isUpdatePhase = useSelector(controller, (s) =>
      s.matches(updatePhase)
    );
    const disabled = useSelector(controller, (state) =>
      inactiveState ? (state.context[inactiveState] as boolean) : false
    );

    useEffect(() => {
      if (isUpdatePhase) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const data = {} as any;
        data[entryKey] = val;
        send({
          type: BaseEvent.setFormData,
          data
        });
      }
    }, [isUpdatePhase]);

    // init();
    /* useEffect(() => {
      if (isUpdatePhase) {
        setVal(state.context[entryKey]);
      }
    }, [isUpdatePhase]);
    */
    // eslint-disable-next-line @typescript-eslint/no-explicit-any

    return (
      <input
        disabled={disabled}
        value={val}
        onChange={(e) => {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          const data = {} as any;
          data[entryKey] = e.target.value;
          send({
            type: BaseEvent.setFormData,
            data
          });
        }}
        step={params.step}
        min={params.min}
        max={params.max}
        type="number"
        className={disabled ? genericInputStyleDisabled : genericInputStyle}
      />
    );
  };
}

export function makeUpdateInput<Context extends ContextType>(
  entryKey: string,
  controller: BaseController<Context>,
  isTextArea = false,
  inactiveState: string | undefined = undefined
) {
  return function UpdateInput() {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [, send] = useActor(controller);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const value: any = useSelector(controller, (s) =>
      s.context[entryKey] === undefined ? "" : s.context[entryKey]
    );
    //  const [val, setVal] = useState<any>(value);

    const disabled = useSelector(controller, (s) =>
      inactiveState ? (s.context[inactiveState] as boolean) || false : false
    );

    /*   useEffect(() => {
      if (state.matches(updatePhase)) {
        setVal(state.context[entryKey]);
      }
    }, [state]);
    */
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const data = {} as any;
    if (isTextArea) {
      return (
        <textarea
          disabled={disabled}
          value={value || ""}
          onChange={(e) => {
            data[entryKey] = e.target.value;
            send({
              type: BaseEvent.setFormData,
              data
            });
          }}
          className={genericTextAreaStyle}
          rows={3}
        />
      );
    }
    return (
      <input
        value={value || ""}
        disabled={disabled}
        onChange={(e) => {
          data[entryKey] = e.target.value;
          send({
            type: BaseEvent.setFormData,
            data
          });
        }}
        type="text"
        className={disabled ? genericInputStyleDisabled : genericInputStyle}
      />
    );
  };
}

export const makeUpdateButton = <Context extends ContextType>(
  controller: BaseController<Context>
) => {
  return function Update(props: { title: string; stage: string }) {
    const { title, stage } = props;
    const [, send] = useActor(controller);
    const data = { stage } as unknown as Partial<Context>;
    return (
      <button
        onClick={() => send({ type: BaseEvent.phase2Start, data })}
        type="button"
        className={blackButtonStyle}
      >
        {title}
      </button>
    );
  };
};
