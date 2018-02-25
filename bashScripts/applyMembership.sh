#!/bin/bash

# This script is used to apply for membership

source settings.conf

#Script to deploy membership contract
mkdir -p ../build/scripts

gethAttachPoint=$GETH_ATTACH_POINT
contractAddrs=$MEMBERSHIP_CONTRACT_DEPLOYED_ADDRS

firstName=$1
lastName=$2
companyURL=$3
linkedInURL=$4
twitterURL=$5

echo "var contractAddrs=\"$contractAddrs\";" > ../build/scripts/settings.js
echo "var firstName=\"$firstName\";" >> ../build/scripts/settings.js
echo "var lastName=\"$lastName\";" >> ../build/scripts/settings.js
echo "var companyURL=\"$companyURL\";" >> ../build/scripts/settings.js
echo "var linkedInURL=\"$linkedInURL\";" >> ../build/scripts/settings.js
echo "var twitterURL=\"$twitterURL\";" >> ../build/scripts/settings.js

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

console.log("Applying membership with details..");

membership.applyForMembership.sendTransaction(firstName, lastName, companyURL, linkedInURL, twitterURL,
    {from : eth.accounts[0], value : web3.toWei(0.1, "ether"), gas : 300000}, function(error, txnHash) {
      if(!error){
        web3.eth.getTransactionReceipt(txnHash, function(error, receipt){
          if(!error) {
            var membershipAppliedEvent = membership.LogMembershipApplied();
            membershipAppliedEvent.watch(function(error, result){
              if (!error) {
                  console.log("Membership applied successfully, application id is " + result.args.applicationId);
              }
            });
        }
      });
    }
});
