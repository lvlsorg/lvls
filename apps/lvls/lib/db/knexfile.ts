// knexfile.ts
import { Knex } from 'knex';
const knex = require('knex');
interface KnexConfig {
  [key: string]: Knex.Config;
}

const configuration = {
  development: {
    client: "better-sqlite3",
    connection: {
      filename: "../test_db/dev.sqlite3"
    },
    migrations: {
      tableName: 'knex_migrations',
      directory: '../migrations'
    },
    useNullAsDefault: true
  },
  production: {
   client: "",
    connection: {
      filename: "../test_db/prod.sqlite3"
    },
    migrations: {
      tableName: 'knex_migrations',
      directory: '../migrations'
    } 
  }
};

export default configuration;
//module.exports = configuration;