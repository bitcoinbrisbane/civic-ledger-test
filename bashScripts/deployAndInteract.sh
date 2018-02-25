#!/bin/bash

# Deploy contract
# Add 3 applications
# Confirm 2 application
# Revoke 1 application

#Script to deploy membership contract
mkdir -p ../build/scripts

echo "var membershipCompiled=`solc --optimize --combined-json abi,bin,interface ../contracts/Membership.sol`" > ../build/scripts/membership.js

#Script to attach geth to ganache
geth --verbosity 3 attach http://127.0.0.1:7545/ << EOF

console.log("loading script ../build/scripts/membership.js");

loadScript("../build/scripts/membership.js");

console.log("Accounts setup...");
var account1 = eth.accounts[0]; console.log("Account 1..." + account1);
var account2 = eth.accounts[1]; console.log("Account 2..." + account2);
var account3 = eth.accounts[2]; console.log("Account 3..." + account3);
var account4 = eth.accounts[3]; console.log("Account 4..." + account4);
var account5 = eth.accounts[4]; console.log("Account 5..." + account5);
var account6 = eth.accounts[5]; console.log("Account 6..." + account6);
var account7 = eth.accounts[6]; console.log("Account 7..." + account7);
var account8 = eth.accounts[7]; console.log("Account 8..." + account8);

console.log("Retrieving membershipContractAbi...");

var membershipContractAbi = membershipCompiled.contracts['../contracts/Membership.sol:Membership'].abi;

console.log("Retrieving membershipContract...");

var membershipContract = web3.eth.contract(JSON.parse(membershipContractAbi));

console.log("Retrieving membershipBinCode...");

var membershipBinCode = "0x" + membershipCompiled.contracts['../contracts/Membership.sol:Membership'].bin;

var deployTxn = {
  from: eth.accounts[0],
  data: membershipBinCode,
  gas: 5000000
};

var txnReceipt;

console.log("Deploying contract...");

var membershipInstance = membershipContract.new(deployTxn, function(error, contract) {
  if(!error){
    txnReceipt = contract.transactionHash;
  }
});

var membershipContractAddrs = web3.eth.getTransactionReceipt(membershipInstance.transactionHash).contractAddress;

console.log("Getting contract instance deployed at " + membershipContractAddrs + " ...");

var membership = membershipContract.at(membershipContractAddrs);

var owner = membership.owner.call();
console.log("Owner of the contract is " + owner);

console.log("Applying membership with details (\"Malcolm\", \"Turnbull\", \"https://gov.au/mturnbull\", \"https://linkedin.com/mturnbull\", \"https://twitter.com/mturnbull\"");

membership.applyForMembership.sendTransaction("Malcolm", "Turnbull", "https://gov.au/mturnbull", "https://linkedin.com/mturnbull", "https://twitter.com/mturnbull",
    {from : account5, value : web3.toWei(1, "ether"), gas : 300000}, function(error, txnHash) {
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

console.log("Applying membership with details (\"Barnaby\", \"Joyce\", \"https://gov.au/bjoyce\", \"https://linkedin.com/bjoyce\", \"https://twitter.com/bjoyce\"");

membership.applyForMembership.sendTransaction("Barnaby", "Joyce", "https://gov.au/bjoyce", "https://linkedin.com/bjoyce", "https://twitter.com/bjoyce",
    {from : account6, value : web3.toWei(0.1, "ether"), gas : 300000}, function(error, txnHash) {
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

console.log("Applying membership with details (\"Tony\", \"Abbott\", \"https://gov.au/tabbott\", \"https://linkedin.com/tabbott\", \"https://twitter.com/tabbott\"");

membership.applyForMembership.sendTransaction("Tony", "Abbott", "https://gov.au/tabbott", "https://linkedin.com/tabbott", "https://twitter.com/tabbott",
    {from : account7, value : web3.toWei(1.1, "ether"), gas : 300000}, function(error, txnHash) {
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

console.log("Applying membership with details (\"Gladys\", \"Berejiklian\", \"https://gov.au/gberejiklian\", \"https://linkedin.com/gberejiklian\", \"https://twitter.com/gberejiklian\"");

membership.applyForMembership.sendTransaction("Gladys", "Berejiklian", "https://gov.au/gberejiklian", "https://linkedin.com/gberejiklian", "https://twitter.com/gberejiklian",
    {from : account8, value : web3.toWei(11, "ether"), gas : 300000}, function(error, txnHash) {
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

console.log("Confirming membership of application 1 with details (\"Malcolm\", \"Turnbull\", \"https://gov.au/mturnbull\", \"https://linkedin.com/mturnbull\", \"https://twitter.com/mturnbull\"");

membership.addMembership.sendTransaction(1, {from : account1, gas : 300000}, function(error, txnHash) {
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

console.log("Confirming membership of application 3 with details (\"Tony\", \"Abbott\", \"https://gov.au/tabbott\", \"https://linkedin.com/tabbott\", \"https://twitter.com/tabbott\"");

membership.addMembership.sendTransaction(3, {from : account1, gas : 300000}, function(error, txnHash) {
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

console.log("Revoking membership of member 2 with details (\"Tony\", \"Abbott\", \"https://gov.au/tabbott\", \"https://linkedin.com/tabbott\", \"https://twitter.com/tabbott\"");

membership.revokeMembership.sendTransaction(2, {from : account1, gas : 300000}, function(error, txnHash) {
      if(!error){
        web3.eth.getTransactionReceipt(txnHash, function(error, receipt){
          if(!error) {
            var membershipRevokedEvent = membership.LogMembershipRevoked();
            membershipRevokedEvent.watch(function(error, result){
              if (!error) {
                  console.log("Membership revoked successfully for member id, " + result.args.memberId);
              }
            });
          }
      });
    }
});

console.log("**************** Overall Status ****************");

console.log("Printing pending application details");

var count = membership.getPendingApplicationCount.call({from : account5, gas : 300000});
  console.log("Total pending application count => ", count);
  for(var i = 0; i < count; i++){
    console.log("Pending application array index #" + count +  " being processed");
    membership.pendingApplicationIds.call(i, {from : account5, gas : 300000}, function(error, pendingApplicationId) {
      if(!error) {
        console.log("Pending application id " + pendingApplicationId +  " being processed");
        membership.getPendingApplicationDetails.call(pendingApplicationId, {from : account5, gas : 300000}, function(error, result) {
          if(!error) {
            console.log("Applicant Eth Addrs => " + result[0]);
            console.log("Applicant First name => " + result[1]);
            console.log("Applicant Last name => " + result[2]);
            console.log("Applicant Company URL => " + result[3]);
            console.log("Applicant LinkedIn URL => " + result[4]);
            console.log("Applicant Twitter URL => " + result[5]);
          }
        });
      }
    });
  }

console.log("Printing member details");

var count = membership.getMemberCount.call({from : account5, gas : 300000});
  console.log("Total member count => ", count);
  for(var i = 0; i < count; i++){
    console.log("Members array index #" + count +  " being processed");
    membership.memberIds.call(i, {from : account5, gas : 300000}, function(error, memberId) {
      if(!error) {
        console.log("Member id " + memberId +  " being processed");
        membership.getMemberDetails.call(memberId, {from : account5, gas : 300000}, function(error, result) {
          if(!error) {
            console.log("Member Eth Addrs => " + result[0]);
            console.log("Member First name => " + result[1]);
            console.log("Member Last name => " + result[2]);
            console.log("Member Company URL => " + result[3]);
            console.log("Member LinkedIn URL => " + result[4]);
            console.log("Member Twitter URL => " + result[5]);
          }
        });
      }
    });
  }

EOF
