// Require the necessary discord.js classes
import * as readline from "readline";
import { SlashCommandBuilder } from '@discordjs/builders';
import { Client, Collection, CommandInteraction, Events, GatewayIntentBits } from 'discord.js';
import * as commands from "../commands";
import * as dotenv from "dotenv";
dotenv.config();

const token = process.env.DISCORD_TOKEN || '';
const guildId = process.env.DISCORD_GUILD_ID || '';
console.log("bofff",token,guildId)
// Create a new client instance
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// When the client is ready, run this code (only once)
// We use 'c' for the event parameter to keep it separate from the already defined 'client'
client.once(Events.ClientReady, async (c) => {
  await commands.deployGuildCommands(client.application?.id || '',guildId , token)
  console.log("added commands");
});


// Login to Discord
client.login(token);
const rl = readline.createInterface({
	  input: process.stdin,
	  output: process.stdout
});

rl.question("Press any key to exit", function() {
	  rl.close();
	  process.exit(0);
})