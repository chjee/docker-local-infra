db = db.getSiblingDB('blog');

db.createUser({
  user: 'devuser',
  pwd: 'devpass3992',
  roles: [{ role: 'readWrite', db: 'blog' }],
});
