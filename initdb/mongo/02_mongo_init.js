const appDbName = process.env.MONGO_APP_DB || 'blog';
const appUser = process.env.DEV_DB_USER || 'devuser';
const appPassword = process.env.DEV_DB_PASSWORD || 'changeme';
const appDb = db.getSiblingDB(appDbName);

appDb.createUser({
  user: appUser,
  pwd: appPassword,
  roles: [{ role: 'readWrite', db: appDbName }],
});
