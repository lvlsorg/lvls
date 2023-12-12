'use client';
import { getMessageToSign } from "@/lib/login";
import React, { use, useEffect } from "react";
import { Login } from "../components/client/LoginComponent";

const Verify = ({
  searchParams = {code: ""}
}) => {

  return (
    <div>
      <div className="flex flex-col items-center justify-center min-h-screen py-2">
        <Login code={searchParams.code}/>
      </div>
    </div>
  );
};

export default Verify;
