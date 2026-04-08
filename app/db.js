const { Pool } = require('pg');

const pool = new Pool({
  user: 'ehotels_user',
  host: 'localhost',
  database: 'ehotels',
  password: 'ehotels123$',
  port: 5432,
});

module.exports = pool;