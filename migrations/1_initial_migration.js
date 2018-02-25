const truffle = require('../truffle.js');

var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer, network, accounts) {
  const pwd = truffle.networks[network].password;

  if(network === "rinkeby"){
    web3.personal.unlockAccount(accounts[0], pwd);
    web3.personal.unlockAccount(accounts[1], pwd);
  }
  deployer.deploy(Migrations);
};
