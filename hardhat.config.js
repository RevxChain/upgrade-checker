require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-contract-sizer");
require("hardhat-gas-reporter");
require('dotenv').config();

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            allowUnlimitedContractSize: false,
            blockGasLimit: 16777216,
            forking: {
                url: process.env.FORK_RPC_URL !== undefined ? process.env.FORK_RPC_URL : "https://eth.llamarpc.com",
                blockNumber: process.env.FORK_BLOCK_NUMBER !== undefined ? process.env.FORK_BLOCK_NUMBER : 24540000,
                enabled: false
            }
        },
        eth: {
            url: process.env.ETH_RPC_URL !== undefined ? process.env.ETH_RPC_URL : "https://eth.llamarpc.com",
            chainId: 1,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        bsc: {
            url: process.env.BSC_RPC_URL !== undefined ? process.env.BSC_RPC_URL : "https://binance.llamarpc.com",
            chainId: 56,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        opbnb: {
            url: process.env.OPBNB_RPC_URL !== undefined ? process.env.OPBNB_RPC_URL : "https://1rpc.io/opbnb",
            chainId: 204,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        arbitrum: {
            url: process.env.ARBITRUM_RPC_URL !== undefined ? process.env.ARBITRUM_RPC_URL : "https://arbitrum.llamarpc.com",
            chainId: 42161,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        base: {
            url: process.env.BASE_RPC_URL !== undefined ? process.env.BASE_RPC_URL : "https://base.llamarpc.com",
            chainId: 8453,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        polygon: {
            url: process.env.POLYGON_RPC_URL !== undefined ? process.env.POLYGON_RPC_URL : "https://polygon.llamarpc.com",
            chainId: 137,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        avalanche: {
            url: process.env.AVALANCHE_RPC_URL !== undefined ? process.env.AVALANCHE_RPC_URL : "https://avalanche-c-chain-rpc.publicnode.com",
            chainId: 43114,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        optimism: {
            url: process.env.OPTIMISM_RPC_URL !== undefined ? process.env.OPTIMISM_RPC_URL : "https://optimism.llamarpc.com",
            chainId: 10,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        mantle: {
            url: process.env.MANTLE_RPC_URL !== undefined ? process.env.MANTLE_RPC_URL : "https://mantle-rpc.publicnode.com",
            chainId: 5000,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        xlayer: {
            url: process.env.XLAYER_RPC_URL !== undefined ? process.env.XLAYER_RPC_URL : "https://xlayer.drpc.org",
            chainId: 196,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        core: {
            url: process.env.CORE_RPC_URL !== undefined ? process.env.CORE_RPC_URL : "https://1rpc.io/core",
            chainId: 1116,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        immutable: {
            url: process.env.IMMUTABLE_RPC_URL !== undefined ? process.env.IMMUTABLE_RPC_URL : "https://rpc.immutable.com",
            chainId: 13371,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        bera: {
            url: process.env.BERA_RPC_URL !== undefined ? process.env.BERA_RPC_URL : "https://rpc.berachain.com/",
            chainId: 80094,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        sonic: {
            url: process.env.SONIC_RPC_URL !== undefined ? process.env.SONIC_RPC_URL : "https://rpc.soniclabs.com/",
            chainId: 146,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        blaze: {
            url: process.env.BLAZE_RPC_URL !== undefined ? process.env.BLAZE_RPC_URL : "https://rpc.blaze.soniclabs.com",
            chainId: 57054,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        manta: {
            url: process.env.MANTA_RPC_URL !== undefined ? process.env.MANTA_RPC_URL : "https://manta-pacific.drpc.org/",
            chainId: 169,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        kaia: {
            url: process.env.KAIA_RPC_URL !== undefined ? process.env.KAIA_RPC_URL : "https://klaytn.drpc.org",
            chainId: 8217,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        blast: {
            url: process.env.BLAST_RPC_URL !== undefined ? process.env.BLAST_RPC_URL : "https://blast.drpc.org",
            chainId: 81457,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        ronin: {
            url: process.env.RONIN_RPC_URL !== undefined ? process.env.RONIN_RPC_URL : "https://ronin.drpc.org",
            chainId: 2020,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        },
        celo: {
            url: process.env.CELO_RPC_URL !== undefined ? process.env.CELO_RPC_URL : "https://celo.drpc.org",
            chainId: 42220,
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
        }
    },

    mocha: {
        timeout: 200000,
    },

    solidity: {
        compilers: [
            {
                version: "0.8.34",
                settings: {
                    viaIR: false,
                    evmVersion: "prague",
                    optimizer: {
                        enabled: true,
                        runs: 1000,
                    },
                },
            },
        ],
    },

    gasReporter: {
        enabled: false,
    },

    contractSizer: {
        alphaSort: false,
        disambiguatePaths: false,
        runOnCompile: false,
        strict: false,
        only: [],
    }
}