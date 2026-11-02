const sql = require('mssql');
require('dotenv').config();

const config = {
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'AquaSootheDB',
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || 'YourStrongPassword123!',
  port: parseInt(process.env.DB_PORT, 10) || 1433,
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true', // true for Azure, false for local
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE !== 'false', // true for local dev self-signed certs
    enableArithAbort: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let poolPromise = null;

async function getPool() {
  if (!poolPromise) {
    poolPromise = sql
      .connect(config)
      .then((pool) => {
        console.log(`[MS SQL] Connected successfully to ${config.server}:${config.port}/${config.database}`);
        return pool;
      })
      .catch((err) => {
        console.error('[MS SQL] Database Connection Failed: ', err.message);
        poolPromise = null;
        throw err;
      });
  }
  return poolPromise;
}

module.exports = {
  sql,
  getPool,
};
