import { SiweMessage } from "siwe";

export interface LoginData {
    message: SiweMessage;
    code: string;
    signature: string;
}