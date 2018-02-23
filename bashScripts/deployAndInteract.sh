#!/bin/bash

#Script to deploy membership contract
mkdir -p ../build/scripts

echo "var membershipCompiled=`solc --optimize --combined-json abi,bin,interface ../contracts/Membership.sol`" > ../build/scripts/membership.js

#Script to attach geth to ganache
geth --verbosity 3 attach http://127.0.0.1:7545/ << EOF

loadScript("../build/scripts/membership.js");

var membershipContractAbi = membershipCompiled.contracts['../contracts/Membership.sol:Membership'].abi;

var membershipContract = web3.eth.contract(JSON.parse(membershipContractAbi));

var membershipBinCode = "0x" + membershipCompiled.contracts['../contracts/Membership.sol:Membership'].bin;

var deployTxn = {
  from: eth.accounts[0],
  data: membershipBinCode,
  gas: 5000000
};

var txnReceipt;

var membershipInstance = membershipContract.new(deployTxn, function(error, contract) {
  if(!error){
    txnReceipt = contract.transactionHash;
  }
});

var membershipContractAddrs = web3.eth.getTransactionReceipt(membershipInstance.transactionHash).contractAddress;

var membership = membershipContract.at(membershipContractAddrs);

var owner = membership.owner.call();
console.log(owner);

EOF
