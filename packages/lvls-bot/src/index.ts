// Require the necessary discord.js classes
import * as readline from "readline";
import { SlashCommandBuilder } from '@discordjs/builders';
import { Client, Collection, CommandInteraction, Events, GatewayIntentBits, Interaction } from 'discord.js';
import * as commands from "./commands";
import * as modals from "./modals";
import * as dotenv from "dotenv";
dotenv.config();

const token = process.env.DISCORD_TOKEN || '';

// Create a new client instance
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// When the client is ready, run this code (only once)
// We use 'c' for the event parameter to keep it separate from the already defined 'client'

// Add a listener for the client's interactionCreate event
client.on(Events.InteractionCreate, async (interaction: Interaction) => {
  if (interaction.isModalSubmit()){
    const customId = interaction.customId
    console.log(interaction.fields.getTextInputValue("exchangeRateInput"))
    const lvlsConfig = modals.configuration.handleModal(interaction);
		await interaction.reply({ content: JSON.stringify(lvlsConfig), ephemeral: true });
    return;
	}
  if (!interaction.isChatInputCommand()) return;
    const command = commands.commandSet[interaction.commandName];
    console.log("chat command", command);
    if (!command) {
      console.error(`No command matching ${interaction.commandName} was found.`);
      return;
    }
  // Execute the command
  try {
    await command.execute(interaction);
  } catch (error) {
    console.log("honey boo boo")
    console.error(error);
    //await interaction.reply({ content: 'An error occurred while executing the command', ephemeral: true });
  }
});

// When the client is ready, run this code (only once)
// We use 'c' for the event parameter to keep it separate from the already defined 'client'
client.once(Events.ClientReady, async (c) => {
  console.log("\nCommands ready\n");
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