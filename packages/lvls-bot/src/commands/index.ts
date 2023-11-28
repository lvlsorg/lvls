import { AutocompleteInteraction, REST, Routes, Client, CommandInteraction, CommandInteractionOptionResolver, SlashCommandBuilder, Collection } from "discord.js";
import config from "./config";
import connect from "./connect";

export interface HandleCommand {
    execute: (interaction: CommandInteraction) => Promise<void>;
}

export const commandSet: Record<string, HandleCommand> = {};
commandSet[config.data.name] = config as HandleCommand;
commandSet[connect.data.name] = connect as HandleCommand;

export const commandData = [
   config.data.toJSON(),
   connect.data.toJSON()
]



export const  deployGuildCommands = async (clientId: string, guildId: string, token: string) => {
// Construct and prepare an instance of the REST module
const rest = new REST().setToken(token);

// and deploy your commands!
	try {
		console.log(`Started refreshing ${commandData.length} application (/) commands.`);

		// The put method is used to fully refresh all commands in the guild with the current set
		const data = await rest.put(
			Routes.applicationGuildCommands(clientId, guildId),
			{ body: commandData },
		);

		console.log(`Successfully reloaded ${commandData.length} application (/) commands.`);
	} catch (error) {
		// And of course, make sure you catch and log any errors!
		console.error(error);
	}

}