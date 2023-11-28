import { generateNonce, SiweMessage } from "siwe";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import querystring from "querystring";
import fetch from "node-fetch";
import axios from "axios";
import { access } from "fs";

dotenv.config();

const { SECRET_KEY } = process.env;
const clientId = process.env.CLIENT_ID || "";
const clientSecret = process.env.CLIENT_SECRET || "";
const jwtSecret = process.env.JWT_SECRET || "";

interface Access {
  access_token: string;
  token_type: string;
  expires_in: number;
  refresh_token: string;
  scope: string;
}

export async function generateNonceJwt(
  accessToken: string,
  tokenType: string
): Promise<string> {
  console.log("past  the oauth token", tokenType, accessToken);
  const response = await axios.get("https://discord.com/api/users/@me", {
    headers: {
      authorization: `${tokenType} ${accessToken}`,
    },
  });
  console.log(response.data);
  const { username } = response.data;

  return username;
}

/*

const response = await axios.get('https://discord.com/api/users/@me', {
    headers: {
      authorization: `${tokenType} ${accessToken}`,
    },
  })
  const {username} = response.json()
  
};
*/

export async function POST(request: Request) {
  const response: Record<string, string> = await request.json();
  console.log("response", response);
  const { code } = response;
  console.log("client:",clientId, clientSecret, code)
  const oauthData = await axios.post(
    "https://discord.com/api/oauth2/token",
    new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code: code.toString(),
      grant_type: "authorization_code",
      redirect_uri: `http://localhost:3000/auth`,
      scope: "identify, guilds, guilds.members.read",
    }).toString(),
    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    }
  );

  const accessData = oauthData.data as Access;
  console.log("oauth data:",oauthData.data)
  const accessToken = accessData.access_token;
  const tokenType = accessData.token_type;
  const jwtUsername = await generateNonceJwt(accessToken, tokenType);
  const payload = {
    username: jwtUsername,
    // Include the user ID to ensure this JWT is only valid for the user it was issued to
    // You can include additional claims here as needed
  };

  const jwtOptions = {
    expiresIn: "1h", // This JWT will be valid for 1 hour
    // Include any other JWT options here as needed
  };

  const token = jwt.sign(payload, jwtSecret, jwtOptions);
  return new Response(token);
}
