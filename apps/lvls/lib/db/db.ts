import knex, { Knex } from 'knex';
import knexfile from './knexfile';
import dotenv from 'dotenv';

dotenv.config();
type environments = 'development' | 'production';
const env = (process.env.NODE_ENV || 'development') as environments;

let dbInstance: Knex | null = null;

export const getDbInstance = () => {
  if (dbInstance === null) {
    dbInstance = knex(knexfile[env]);
  }

  return dbInstance;
}

