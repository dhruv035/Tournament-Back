require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/41a851bc1fbc44eea67f4e84fe707b8c`,
      accounts: []
    }
  },
  etherscan: {
    apiKey: ``
  }
};
