"use client";
import React, { useEffect, useState } from "react";
import validator from "@rjsf/validator-ajv8";
import Form, { withTheme } from "@rjsf/core";
import { RJSFSchema, UiSchema } from "@rjsf/utils";
import classnames from "classnames";
import { lvlsUiTheme } from "./forms/lvls-ui-theme/lvlsUiTheme";
import { makeUpdateButton, makeUpdateInput } from "./GenericComponents";
import { lvlsLaunchController } from "@/lib/service";
import { useActor, useSelector } from "@xstate/react";
import { Stages } from "../../../lib/controllers/lvlsLaunchMachine";
import {
  BaseEvent,
  BaseStates,
  CreateBaseMachineState
} from "@/lib/controllers/formMachine";
import { useRouter } from "next/router";
import Step from "./StepsComponent";

/*const ThemedForm = withTheme(lvlsUiTheme);

interface MyUiSchema extends UiSchema {
  "ui:options"?: {};
}

const schema: RJSFSchema = {
  type: "object",
  properties: {
    name: { type: "string" },
    age: { type: "number" }
  }
};
const nameStyles = "text-blue-200 border rounded-md py-20";
const uiSchema: MyUiSchema = {
  name: {
    "ui:widget": "text",
    "ui:title": "Name"
  },
  age: {
    "ui:widget": "updown"
  }
};*/

export const ConfigListenerComponent = () => {
  const [state, send] = useActor(lvlsLaunchController);
  const context = useSelector(
    lvlsLaunchController,
    (s: CreateBaseMachineState) => s.context
  );
  const isStateComplete = useSelector(
    lvlsLaunchController,
    (s: CreateBaseMachineState) => s.matches(BaseStates.complete)
  );
  const isPhase2End = useSelector(
    lvlsLaunchController,
    (s: CreateBaseMachineState) => s.matches(BaseStates.phase2End)
  );
  //  const router = useRouter();

  useEffect(() => {
    if (context) {
      send({
        type: BaseEvent.phase1Start,
        data: {}
      });
    }
  }, [context]);
  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  }, [context]);

  useEffect(() => {
    if (isPhase2End) {
      //  send({ type: BaseEvent.phase3Start, data: {} });
    }
    if (isStateComplete) {
      // TODO: we shouldnt be using send() here. we should be using xstate actions
      send({ type: BaseEvent.finished, data: {} });
      send({ type: BaseEvent.reset, data: {} });
      // router.replace(``, {});
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isStateComplete, isPhase2End, state]);
  return <></>;
};

const formData = {};
const TokenOwnerInput = makeUpdateInput("owner", lvlsLaunchController, false);

const LaunchLvlButton = makeUpdateButton(lvlsLaunchController);

export const MyForm = () => {
  const totalSteps = 5;
  const [currentStep, setCurrentStep] = useState(1);

  const handleNextStep = () => {
    setCurrentStep((prevStep) => Math.min(prevStep + 1, totalSteps));
  };

  const handlePrevStep = () => {
    setCurrentStep((prevStep) => Math.max(prevStep - 1, 1));
  };

  const onSubmit = (data: any) => {
    console.log(data);
  };
  return (
    <div className="container flex flex-col items-center justify-center">
      <div className="xs:w-full sm:w-1/2 flex flex-col items-center justify-center">
        <div className="text-2xl w-full p-10">
          Step 1 - Launch Lvls Contract
        </div>
        <div className="text-lg w-full">Owner Address</div>
        <TokenOwnerInput />
        <div className="p-20">
          <LaunchLvlButton
            title={"Launch Lvl"}
            stage={"lvlLaunch"}
          ></LaunchLvlButton>
        </div>
      </div>
      <div>
        <div className="flex items-center space-y-4">
          <div className="flex space-x-4">
            {Array.from({ length: 4 }).map((_, index) => (
              <Step key={index} step={index + 1} currentStep={currentStep} />
            ))}
          </div>
        </div>
      </div>
      <div className="flex space-x-4">
        <button onClick={handlePrevStep} disabled={currentStep === 1}>
          Previous
        </button>

        <button onClick={handleNextStep} disabled={currentStep === totalSteps}>
          Next
        </button>
      </div>
    </div>
  );
  /*
  return (
    <div className="container flex items-center justify-center">
      <div className="xs:w-full sm:w-1/2 flex items-center justify-center">
        <div className="max-w-2xl">
          <ThemedForm
            schema={schema}
            uiSchema={uiSchema}
            formData={formData}
            onSubmit={onSubmit}
            validator={validator}
          />
        </div>
      </div>
    </div>

  );
  */
};
