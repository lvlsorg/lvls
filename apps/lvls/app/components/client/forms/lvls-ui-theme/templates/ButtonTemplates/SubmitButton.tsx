import {
  getSubmitButtonOptions,
  FormContextType,
  RJSFSchema,
  StrictRJSFSchema,
  SubmitButtonProps
} from "@rjsf/utils";
import React from "react";

/** The `SubmitButton` renders a button that represent the `Submit` action on a form
 */
export default function SubmitButton<
  T = any,
  S extends StrictRJSFSchema = RJSFSchema,
  F extends FormContextType = any
>({ uiSchema }: SubmitButtonProps<T, S, F>) {
  const {
    submitText,
    norender,
    props: submitButtonProps = {}
  } = getSubmitButtonOptions<T, S, F>(uiSchema);
  if (norender) {
    return null;
  }
  return (
    <div>
      <button
        type="submit"
        {...submitButtonProps}
        className={`bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-4 ${
          submitButtonProps.className || ""
        }`}
      >
        {submitText}
      </button>
    </div>
  );
}
