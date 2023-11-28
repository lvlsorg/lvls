import { getDbInstance } from "./db";

export interface UserMetadata {
  username: string;
  address: string;
  chain_id: number;
}

export interface Access {
  username: string;
  refresh_token: string;
  access_token: string;
  expires_in: number;
}

export const UserFactory = () => {
  const db = getDbInstance();

  const createAccess = async (access: Access): Promise<number[]> => {
    return db("access").upsert(access);
  };

  const create = async (user: UserMetadata): Promise<number[]> => {
    return db("user_metadata").upsert(user);
  };

  const read = async (
    username: string,
    chain_id: number
  ): Promise<UserMetadata[]> => {
    return db("user_metadata")
      .join("access", "user_metadata.username", "access.username")
      .where({
        "user_metadata.username": username,
        "user_metadata.chain_id": chain_id,
      });
  };

  const update = async (
    username: string,
    chain_id: number,
    user: UserMetadata
  ): Promise<number> => {
    return db("user_metadata").where({ username, chain_id }).update(user);
  };

  const remove = async (
    username: string,
    chain_id: number
  ): Promise<number> => {
    return db("user_metadata").where({ username, chain_id }).del();
  };

  return {
    create,
    createAccess,
    read,
    update,
    remove,
  };
};
