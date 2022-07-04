require("@nomiclabs/hardhat-etherscan")
require('dotenv').config();
const { numberOfWinners, scriptionId } = process.env;
module.exports = [
    numberOfWinners, 
    scriptionId 
];
//npx hardhat verify --constructor-args scripts/verify.js 0xb967BEE15de3C6195Cd921C5D9EC0732919c36f9 --network rinkeby --show-stack-traces 


