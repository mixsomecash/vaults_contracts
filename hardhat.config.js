require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/SeEto03j0b_OiWB6dRAxtvQ4FaF7cjXM",
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
