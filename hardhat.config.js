require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config({ path: ".env" });

const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: ALCHEMY_API_KEY_URL,
      accounts: [RINKEBY_PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: {
      rinkeby: 'CTFJH3VK8H29BRRUAEH2CAFZ3F1BKF1DT2'
    }
  }
}