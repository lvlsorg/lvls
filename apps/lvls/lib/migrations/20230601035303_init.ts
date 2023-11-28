import { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
    await knex.schema.createTable('access', table => {
        table.increments('id').primary();
        table.string('refresh_token').notNullable();
        table.string('access_token').notNullable();
        table.integer('expires_in').notNullable();
        table.string('username').notNullable().unique();
    });

    await knex.schema.createTable('user_metadata', table => {
        table.increments('id').primary();
        table.integer('chain_id').notNullable();
        table.string('address').notNullable();
        table.string('username').references('username').inTable('access');
    });
}

export async function down(knex: Knex): Promise<void> {
    await knex.schema.dropTable('user_metadata');
    await knex.schema.dropTable('access');
}