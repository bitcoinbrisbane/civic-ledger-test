# Membership smart contract

A membership smart contract allows an owner to add and revoke memberships.

The Member’s properties include
* First Name
* Last Name
* Company url
* LinkedIn
* Twitter

Members can apply with an Ethereum payment.

## Evaluation criteria

The app has been built using the truffle react box. Integrating the smart contracts to a full fledged DApp is out of scope
for this evaluation and has been left as Work in progress.

* [x] Create truffle unit tests
> Tests are located in **test/** directory
* [x] Bash scripts
> Scripts for deployment and interaction are located in the **bashScripts/** directory and also provided in the sections below
* [x] Commit to github
> Repository link - **https://github.com/palanisn/civic-ledger-test**
* [x] Deploy to rinkeby
> The contract is deployed to the Rinkeby test net at *[0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783](https://rinkeby.etherscan.io/address/0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783)*, transaction hash **[0x4188e2c373998d80c1cb08a2ced28d22150caa767f5680171e508555ac615a06](https://rinkeby.etherscan.io/tx/0x4188e2c373998d80c1cb08a2ced28d22150caa767f5680171e508555ac615a06)**
* [x] Share link and transaction ID when done
> The contract is deployed to the Rinkeby test net at *[0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783](https://rinkeby.etherscan.io/address/0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783)*, transaction hash **[0x4188e2c373998d80c1cb08a2ced28d22150caa767f5680171e508555ac615a06](https://rinkeby.etherscan.io/tx/0x4188e2c373998d80c1cb08a2ced28d22150caa767f5680171e508555ac615a06)**

The following data has been setup in the smart contract

| First name | Last name | Company URL | LinkedIn URL | Twitter URL | Status | Application Id |
| :--------: | :--------:| :---------: | :---------:  | :---------: | :----: | :---------: |
| Malcolm | Turnbull | https://gov.au/mturnbull | https://linkedin.com/mturnbull | https://twitter.com/mturnbull | Applied | 1 |
| Tony | Abbott | https://gov.au/tabbott | https://linkedin.com/tabbott | https://twitter.com/tabbott | Applied | 2 |
| Barnaby | Joyce | https://gov.au/bjoyce | https://linkedin.com/bjoyce | https://twitter.com/bjoyce | Applied | 3 |
| Gladys | Berejiklian | https://gov.au/gberejiklian | https://linkedin.com/gberejiklian | https://twitter.com/gberejiklian | Applied | 4 |

## Tools used
* Truffle
* ganache
* geth
* solhint
* solc
* solc-js

## Using Truffle to compile and deploy contracts
This truffle project is configured with 2 networks - `Ganache` and `Rinkeby`

>*Note:* If deploying to Rinkeby, verify configuration settings in **truffle.js**

Compile smart contracts
> truffle compile --network ganache

Test smart contracts
> truffle test --network ganache

Migrate / Deploy smart contracts
> truffle migrate --network ganache

## Using geth to compile, deploy and interact with smart contracts

>*Note:* If deploying to Rinkeby, verify configuration settings in **bashScripts/settings.conf**

### Contract owner account details

>*Note:* Only contract owner is able to confirm / revoke membership applications

* Public address [0x16c51fa87f85216606a860f45eb1bc6f363fda00](https://rinkeby.etherscan.io/address/0x16c51fa87f85216606a860f45eb1bc6f363fda00)
* Password `secret`
* Keystore file located at `keyStore\UTC--2018-02-25T11-45-54.567161554Z--16c51fa87f85216606a860f45eb1bc6f363fda00`

Compile and deploy Membership smart contract
```javascript
loadScript("../build/scripts/membership.js");
var membershipContractAbi = membershipCompiled.contracts['../contracts/Membership.sol:Membership'].abi;
var membershipContract = web3.eth.contract(JSON.parse(membershipContractAbi));
var membershipBinCode = "0x" + membershipCompiled.contracts['../contracts/Membership.sol:Membership'].bin;
personal.unlockAccount(eth.accounts[0], "secret");
var deployTxn = {from: eth.accounts[0], data: membershipBinCode, gas : 6700000, gasPrice: web3.toWei("30", "gwei")};
var membershipInstance = membershipContract.new(deployTxn);
var membershipContractAddrs = web3.eth.getTransactionReceipt(membershipInstance.transactionHash).contractAddress;
```

Interact with membership contract
Apply for membership
```javascript
var membershipContractAddrs = "0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783";
var membership = membershipContract.at(membershipContractAddrs);

var membershipAppliedEvent = membership.LogMembershipApplied(function(error, result) {
  if (!error){
    var jsonObj = JSON.parse(JSON.stringify(result));
    var argsObj = (jsonObj.args);
    console.log("Application id " + argsObj.applicationId);
  }
});

personal.unlockAccount(eth.accounts[0], "secret");
var application = membership.applyForMembership.sendTransaction("John", "Rambo", "https://jrambo.com", "https://linkedin.com/jrambo", "https://twitter.com/jrambo", {from : eth.accounts[0], value : web3.toWei(0.1, "ether"), gas : 6700000, gasPrice: web3.toWei("30", "gwei")});
var txnReceipt = web3.eth.getTransactionReceipt(application);

membershipAppliedEvent.stopWatching();
```

Confirm membership
```javascript
var membershipContractAddrs = "0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783";
var membership = membershipContract.at(membershipContractAddrs);

var membershipAddedEvent = membership.LogMembershipAdded(function(error, result) {
  if (!error){
    var jsonObj = JSON.parse(JSON.stringify(result));
    var argsObj = (jsonObj.args);
    console.log("Application id " + argsObj.applicationId);
    console.log("Member id " + argsObj.memberId);
  }
});

personal.unlockAccount(eth.accounts[0], "secret");
var confirmation = membership.addMembership.sendTransaction(1, {from : eth.accounts[0], gas : 6700000, gasPrice: web3.toWei("30", "gwei")});
var txnReceipt = web3.eth.getTransactionReceipt(confirmation);

membershipAddedEvent.stopWatching();
```

Revoke membership
```javascript
var membershipContractAddrs = "0x5afe61f2c0565b4756c9cd1c55262d4a4a22b783";
var membership = membershipContract.at(membershipContractAddrs);

var membershipRevokedEvent = membership.LogMembershipRevoked(function(error, result) {
  if (!error){
    var jsonObj = JSON.parse(JSON.stringify(result));
    var argsObj = (jsonObj.args);
    console.log("Member id " + argsObj.memberId);
  }
});

personal.unlockAccount(eth.accounts[0], "secret");
var revoke = membership.revokeMembership.sendTransaction(1, {from : eth.accounts[0], gas : 6700000, gasPrice: web3.toWei("30", "gwei")});
var txnReceipt = web3.eth.getTransactionReceipt(revoke);

membershipRevokedEvent.stopWatching();
```


### TODO
* [x] Events should have Log prefix
* [x] Add events for transfer and self destruct
* [x] Truffle Tests
  * [x] Add tests for all require statements
  * [x] Split self destruct and transfer to separate suites
* [x] Shell script for deployment
* [x] Shell script for interaction / use cases
* [x] Deploy to Rinkeby & test
* [ ] Integrate into React app - Integrating the smart contracts to a full fledged DApp is out of scope
for this evaluation and has been left as Work in progress.
