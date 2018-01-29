'use strict'

const path = require('path')
const address = 'YOUR_HOT_WALLET_RIPPLE_ADDRESS'
const secret = 'YOUR_HOT_WALLET_RIPPLE_SECRET'

const peerPlugin = {
  relation: 'peer',
  plugin: 'ilp-plugin-xrp-paychan',
  assetCode: 'XRP',
  assetScale: 6,
  balance: {
    maximum: '10000',
    settleThreshold: '-5000',
    settleTo: '0'
  },
  options: {
    server: 'SERVER_URI_GIVEN_TO_YOU_BY_YOUR_PEER',
    rippledServer: 'wss://s1.ripple.com',
    secret,
    address,
    peerAddress: 'RIPPLE_ADDRESS_OF_PEER'
  }
}

const miniAccounts = {
  relation: 'child',
  plugin: 'ilp-plugin-mini-accounts',
  assetCode: 'XRP',
  assetScale: 6,
  options: {
    port: 7768
  }
}

const connectorApp = {
  name: 'connector',
  env: {
    DEBUG: 'ilp*,connector*',
    CONNECTOR_BACKEND: 'one-to-one',
    CONNECTOR_FX_SPREAD: '0',
    CONNECTOR_STORE: 'ilp-store-simpledb',
    CONNECTOR_STORE_CONFIG: JSON.stringify({
      host: 'sdb.us-east-1.amazonaws.com',
      domain: 'connector',
      role: 'connector-instance'
    })
    CONNECTOR_ACCOUNTS: JSON.stringify({
      peer: peerPlugin,
      local: miniAccounts
    })
  },
  script: path.resolve(__dirname, 'src/index.js')
}

module.exports = { apps: [ connectorApp ] }
