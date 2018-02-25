#!/bin/bash

# This script is used to confirm membership

source settings.conf

#Script to deploy membership contract
mkdir -p ../build/scripts

gethAttachPoint=$GETH_ATTACH_POINT
contractAddrs=$MEMBERSHIP_CONTRACT_DEPLOYED_ADDRS

applicationId=$1

echo "var contractAddrs=\"$contractAddrs\";" > ../build/scripts/settings.js
echo "var applicationId=\"$applicationId\";" >> ../build/scripts/settings.js

#Script to attach geth to ganache
geth attach $gethAttachPoint << EOF


console.log("loading script ../build/scripts/membership.js");

loadScript("../build/scripts/membership.js");

console.log("loading script ../build/scripts/settings.js");

loadScript("../build/scripts/settings.js");

console.log("Retrieving membershipContractAbi...");

var membershipContractAbi = membershipCompiled.contracts['../contracts/Membership.sol:Membership'].abi;

console.log("Retrieving membershipContract...");

var membershipContract = web3.eth.contract(JSON.parse(membershipContractAbi));

console.log("Getting contract instance deployed at " + contractAddrs + "...");

var membership = membershipContract.at(contractAddrs);

console.log("Confirming membership of applicant with application Id.." + applicationId);

membership.addMembership.sendTransaction(applicationId, {from : eth.accounts[0], gas : 300000}, function(error, txnHash) {
      if(!error){
        web3.eth.getTransactionReceipt(txnHash, function(error, receipt){
          if(!error) {
            var membershipAddedEvent = membership.LogMembershipAdded();
            membershipAddedEvent.watch(function(error, result){
              if (!error) {
                  console.log("Membership confirmed successfully for application " + result.args.applicationId + ", member id is " + result.args.memberId);
              }
            });
        }
      });
    }
});
