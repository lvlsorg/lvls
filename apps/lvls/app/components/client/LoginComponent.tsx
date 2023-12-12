"use client";

import { getMessageToSign } from "@/lib/login";
import React, { useEffect, useState } from "react";
import { SiweMessage } from "siwe";

export const Login = (props: { code: string }) => {
  const [sig, setSig] = useState<string>("");
  const [message, setMessage] = useState<SiweMessage>();
  useEffect(() => {
    const foo = async () => {
      if (props.code) {
        const { signature, message } = await getMessageToSign(props.code);
        setSig(signature);
        setMessage(message);
      }
    };
    foo();
  }, []);
  useEffect(() => {
    if (sig && message && props.code) {
      const updateLogin = async () => {
        const res = await fetch(`api/verify`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({ message, sig, code: props.code })
        });
      };
      updateLogin();
    }
  }, [sig]);
  return <div></div>;
};
