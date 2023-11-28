import { SlashCommandBuilder } from '@discordjs/builders';
import { AutocompleteInteraction, ActionRowBuilder, ChatInputCommandInteraction, CommandInteraction, CommandInteractionOptionResolver, MessageComponentInteraction } from 'discord.js';
import { configuration } from '../modals';

const OAUTH2_URL = "https://discord.com/api/oauth2/authorize?client_id=1111698571142643742&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fconfig&response_type=code&scope=identify%20guilds%20guilds.members.read"
const command = {
  data: new SlashCommandBuilder()
    .setName('lvls-connect')
    .setDescription('Connect your username and discordId to your wallet address'),

  async execute(interaction: ChatInputCommandInteraction) {
    // Parse the command arguments
    await interaction.reply(`Connect your wallet with the following link: ${OAUTH2_URL}`)
    return;
  }

};


export default command;