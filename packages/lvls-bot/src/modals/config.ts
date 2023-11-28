import {
  ActionRowBuilder,
  EmbedBuilder,
  Interaction,
  ModalBuilder,
  TextInputBuilder,
  TextInputStyle,
} from "discord.js";

export interface LvlsConfig {
  exchangeRate: number;
  decayRate: number;
  penaltyRate: number;
  rewardsToken: string;
}

export const handleModal = (interaction: Interaction): LvlsConfig => {
  if (interaction.isModalSubmit()) {
    const exchangeRate = parseInt(
      interaction.fields.getTextInputValue("exchangeRateInput")
    );
    const decayRate = parseInt(
      interaction.fields.getTextInputValue("decayRateInput")
    );
    const penaltyRate = parseInt(
      interaction.fields.getTextInputValue("penaltyRateInput")
    );
    const rewardsToken =
      interaction.fields.getTextInputValue("rewardsTokenInput");
    return {
      exchangeRate,
      decayRate,
      penaltyRate,
      rewardsToken,
    };
  }
  throw new Error("Invalid modal");
};

export const configurationModal = (): ModalBuilder => {
  const modal = new ModalBuilder()
    .setTitle("Lvls Configuration")
    .setCustomId("lvlsConfigModal");
  const inputs = [
    new TextInputBuilder()
      .setCustomId("exchangeRateInput")
      .setLabel("Set the rewards/xp exchange rate")
      .setPlaceholder("2000")
      .setRequired(false)
      .setStyle(TextInputStyle.Short),
    new TextInputBuilder()
      .setCustomId("decayRateInput")
      .setLabel("Set the decay rate")
      .setRequired(false)
      .setPlaceholder("5")
      .setStyle(TextInputStyle.Short),
    new TextInputBuilder()
      .setCustomId("penaltyRateInput")
      .setLabel("Set the early burn penalty rate")
      .setPlaceholder("200")
      .setRequired(false)
      .setStyle(TextInputStyle.Short),
    new TextInputBuilder()
      .setCustomId("rewardsTokenInput")
      .setLabel("Set the reward token address")
      .setRequired(false)
      .setPlaceholder("0x00000")
      .setStyle(TextInputStyle.Short),
  ];
  modal.addComponents(
    inputs.map((input) =>
      new ActionRowBuilder<TextInputBuilder>().addComponents(input)
    )
  );
  return modal;
};
