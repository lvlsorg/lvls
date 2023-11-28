import { SlashCommandBuilder, CommandInteraction, CommandInteractionOptionResolver, AutocompleteInteraction } from "discord.js";

export interface Command {
    data: SlashCommandBuilder;
    execute: (interaction: CommandInteraction, options: CommandInteractionOptionResolver | AutocompleteInteraction) => Promise<void>;
}

