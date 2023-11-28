'use client';
import { SiweMessage } from "siwe";
import { ethers } from "ethers";
declare global {
    interface Window {
        ethereum?: any;
    }
}

export async function getAccounts(): Promise<string[]> {
    if (typeof window !== "undefined" && window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts"
        });
        return accounts;
      } catch (error) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        if ((error as any).message.includes("eth_requestAccounts")) {
          return window.ethereum.request({
            method: "wallet_requestPermissions",
            params: [{ eth_accounts: {} }]
          });
        }
      }
    }
    return [];
  }

export async function getMessageToSign(code: string) {
    const etherProvider = new ethers.providers.Web3Provider(window.ethereum as any);
    const res = await fetch(`api/nonce`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json' // specify JSON data
      },
      body: JSON.stringify({code})
    }, );
   const statement = await res.text();

   // const accountsRequest = await etherProvider.send("eth_requestAccounts", []);
    // const signer = etherProvider.getSigner();
    //const upAddress = await signer.getAddress();
    const upAddress = await getAccounts();
    // TODO note this chainID is wrong shoudl be lukso chainID
    const message = new SiweMessage({
        chainId: 1,
        domain: window.location.host,
        address: ethers.utils.getAddress(upAddress[0]),
        statement: statement,
        uri: window.location.origin,
        version: "1",
        //chainId: 2828, // For LUKSO L16
        resources: ["https://lvls.github.com"],
    });
    console.log(message)
    const siweMessage = message.prepareMessage();
    // const signature = await etherProvider.send('eth_sign', [upAddress[0], siweMessage]);
    const signature = await etherProvider.send('personal_sign', [ethers.utils.getAddress(upAddress[0]), siweMessage]);
    return {message, signature};
}
