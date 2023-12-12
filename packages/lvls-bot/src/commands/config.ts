import { SlashCommandBuilder } from '@discordjs/builders';
import { AutocompleteInteraction, ActionRowBuilder, ChatInputCommandInteraction, CommandInteraction, CommandInteractionOptionResolver, MessageComponentInteraction } from 'discord.js';
import { configuration } from '../modals';

// Define the command
const command = {
  data: new SlashCommandBuilder()
    .setName('lvls-config')
    .setDescription('Set the configuration for the lvls-bot')
    .addSubcommand((subcommand) =>
      subcommand
        .setName('new-config')
        .setDescription('Set the configuration for the lvls-bot') 
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName('exchange-rate')
        .setDescription('Set the exchange rate for the rewards token')
        .addNumberOption((option) =>
          option.setName('value').setDescription('The exchange rate value').setRequired(true)
        )
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName('decay-rate')
        .setDescription('Set the decay rate for the reputation score')
        .addNumberOption((option) =>
          option.setName('value').setDescription('The decay rate value').setRequired(true)
        )
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName('penalty-rate')
        .setDescription('Set the penalty rate for negative actions')
        .addNumberOption((option) =>
          option.setName('value').setDescription('The penalty rate value').setRequired(true)
        )
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName('rewards-token')
        .setDescription('Set the address of the rewards token')
        .addStringOption((option) =>
          option.setName('value').setDescription('The rewards token address').setRequired(true)
        )
    ),

  async execute(interaction: ChatInputCommandInteraction) {
    // Parse the command arguments
    const subcommand = interaction.options.getSubcommand(true);
    console.log("subcommand", subcommand);

    let value: number | string;
    switch (subcommand) {
      case 'exchange-rate':
      case 'decay-rate':
      case 'penalty-rate':
        value = interaction.options.getNumber('value', true);
        if (isNaN(Number(value)) || Number(value) <= 0) {
          await interaction.reply(`Invalid ${subcommand} value`);
          return;
        }
       await interaction.reply('Configuration set successfully');
        break;
      case 'rewards-token':
        value = interaction.options.getString('value', true);
        if (!value.startsWith('0x')) {
          await interaction.reply('Invalid rewards token address');
          return;
        }
        break;
      case 'new-config':{
        const modal = configuration.configurationModal();
        await interaction.showModal(modal)
        return;
      }
      default:
        await interaction.reply('Invalid subcommand');
        return;
    }
  }

};


export default command;