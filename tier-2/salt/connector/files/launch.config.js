'use strict'

const path = require('path')
const address = 'YOUR_HOT_WALLET_RIPPLE_ADDRESS'
const secret = 'YOUR_HOT_WALLET_RIPPLE_SECRET'

const parentPlugin = {
  relation: 'parent',
  plugin: 'ilp-plugin-xrp-asym-client',
  assetCode: 'XRP',
  assetScale: 9,
  options: {
    server: 'btp+wss://YOUR_PARENT_HOST',
    address,
    secret
  }
}

const miniAccounts = {
  relation: 'child',
  plugin: 'ilp-plugin-mini-accounts',
  assetCode: 'XRP',
  assetScale: 9,
  options: {
    port: 7768
  }
}

const connectorApp = {
  name: 'connector',
  env: {
    DEBUG: 'ilp*,connector*',
    CONNECTOR_ENV: 'production',
    CONNECTOR_BACKEND: 'one-to-one',
    CONNECTOR_ADMIN_API: true,
    CONNECTOR_ADMIN_API_PORT: 7769,
    CONNECTOR_SPREAD: '0',
    CONNECTOR_STORE: 'ilp-store-simpledb',
    CONNECTOR_STORE_CONFIG: JSON.stringify({
      // Add this line if you changed your region. Set it to you AWS region.
      // host: 'sdb.us-east-1.amazonaws.com',
      domain: 'connector',
      role: 'connector-instance'
    }),
    CONNECTOR_ACCOUNTS: JSON.stringify({
      parent: parentPlugin,
      local: miniAccounts
    })
  },
  script: path.resolve(__dirname, 'src/index.js')
}

module.exports = { apps: [ connectorApp ] }
