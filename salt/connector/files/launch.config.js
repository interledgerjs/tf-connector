'use strict'

const path = require('path')

const parentPlugin = {
  relation: 'parent',
  plugin: 'ilp-plugin-xrp-asym-client',
  assetCode: 'XRP',
  assetScale: 6,
  options: {
    server: 'btp+ws://:<GENERATE_SECRET>@<YOUR_PARENT_HOST>',
    secret: '<YOUR_RIPPLE_HOT_WALLET_SECRET>'
  }
}

const connectorApp = {
  name: 'connector',
  env: {
    DEBUG: 'ilp*,connector*',
    CONNECTOR_BACKEND: 'one-to-one',
    CONNECTOR_FX_SPREAD: '0',
    CONNECTOR_STORE_PATH: '/var/lib/connector',
    CONNECTOR_ACCOUNTS: JSON.stringify({
      parent: parentPlugin
    })
  },
  script: path.resolve(__dirname, 'src/index.js')
}

module.exports = { apps: [ connectorApp ] }
