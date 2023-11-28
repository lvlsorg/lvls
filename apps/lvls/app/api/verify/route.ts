import { ethers } from "ethers";
import { SiweMessage } from "siwe";
import jwt from "jsonwebtoken";
import * as dotenv from "dotenv";
dotenv.config();
const jwtSecret = process.env.JWT_SECRET || "";
export async function POST(request: Request) {
  const result = await request.json();
  const { message, code, sig } = result;
  console.log(result)
  if (!jwt.verify(message.statement,jwtSecret)) {
    return new Response("Message could not be verified", { status: 400 });
  }
  const siweMessage =new  SiweMessage({...message, chainId: 1})
  //const siweMessage = new SiweMessage(message);
  const verified = await siweMessage.verify({ signature: sig });
  if(verified) {
    const decodedMessage =jwt.decode((verified.data as any).statement)
    console.log("decodedMessage", decodedMessage);
  }
  return new Response(`${verified ? "Account verified" : "Error verifying"}`, {
    status: verified ? 200 : 400,
  });
}
