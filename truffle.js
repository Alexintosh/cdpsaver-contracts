const path = require("path");

const dotenv           = require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = process.env.ETHEREUM_ACCOUNT_MNEMONIC;

module.exports = {
  networks: {
    mainnet: {
        provider: function() {
            return new HDWalletProvider(mnemonic, "https://mainnet.decenter.com");
        },
        network_id: '1',
        gasPrice: 5000000000, // 5 gwei
    },
    kovan: {
        provider: function() {
            return new HDWalletProvider(mnemonic, "https://kovan.decenter.com", 0, 15);
        },
        network_id: '42',
        gasPrice: 3000000000,
        confirmations: 2
    },
    rinkeby: {
        provider: function() {
            return new HDWalletProvider(mnemonic, process.env.RINKEBY_INFURA_ENDPOINT, 0, 10);
        },
        network_id: '4',
    },
    test: {
        provider: function() {
            return new HDWalletProvider(mnemonic, 'http://127.0.0.1:8545/');
        },
        network_id: '*',
    },
    development: {
        host: "127.0.0.1",     // Localhost (default: none)
        port: 8545,            // Standard Ethereum port (default: none)
        network_id: "*",       // Any network (default: none)
    },
    dydx: {
        host: "127.0.0.1",     // Localhost (default: none)
        port: 8445,            // Standard Ethereum port (default: none)
        network_id: "1001",       // Any network (default: none)
    }
  },
  compilers: {
    solc: {
      version: "0.5.7",
    }
 },
}
