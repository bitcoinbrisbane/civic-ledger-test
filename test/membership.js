//Test for Membership contract

var Membership = artifacts.require("./Membership.sol");

contract('Membership - tests for ownership, applying membership, confirm & revoke membership', async (accounts) => {

  const account1 = accounts[0]; //0x627306090abaB3A6e1400e9345bC60c78a8BEf57
  const account2 = accounts[1]; //0xf17f52151EbEF6C7334FAD080c5704D77216b732
  const account3 = accounts[2]; //0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef
  const account4 = accounts[3]; //0x821aEa9a577a9b44299B9c15c88cf3087F3b5544
  const account5 = accounts[4]; //0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2
  const account6 = accounts[5]; //0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e
  const account7 = accounts[6]; //0x2191eF87E392377ec08E7c08Eb105Ef5448eCED5

  // Before this test, the contract owner is account1
  // After this test, the contract owner is account1
  it("should instantiate owner as the contract creator", async () => {
    let membershipInstance = await Membership.deployed();
    let owner = await membershipInstance.owner.call();
    let errorMsg = "Expected contract creator(" + account1 + ") to be the owner but got " + owner + " as the owner";
    assert.equal(owner, account1, errorMsg);
  });

  // Before this test, the contract owner is account1
  // After this test, the contract owner is account2
  it("should allow owner to transfer ownership", async () => {
    let membershipInstance = await Membership.deployed();
    let previousOwner = await membershipInstance.owner.call();
    await membershipInstance.transferOwnership(account2, {from : account1});
    let newOwner = await membershipInstance.owner.call();
    let errorMsg = "Expected owner" + account2 + " , actual owner " + newOwner;
    assert.equal(newOwner, account2, errorMsg);
  });

  // Before this test, the contract owner is account2
  // After this test, the contract owner is account2
  it("should not allow unknown account to transfer ownership", async () => {
    let membershipInstance = await Membership.deployed();
    let previousOwner = await membershipInstance.owner.call();
    try{
      await membershipInstance.transferOwnership(account3, {from : account1});
    } catch(error){
      let newOwner = await membershipInstance.owner.call();
      let errorMsg = "The ownership transfer should fail if not initiated by contract owner";
      assert.equal(newOwner, account2, errorMsg);
    }
  });

  it("should apply for membership", async () => {
    let membershipInstance = await Membership.deployed();

    let applicationId1, applicationId2, applicationId3;
    try{
      let txn1 = await membershipInstance.applyForMembership("Malcolm", "Turnbull", "https://gov.au/mturnbull", "https://linkedin.com/mturnbull", "https://twitter.com/mturnbull", {from : account4, value : web3.toWei(1, "ether")});
      //console.log(txn1);
      for(let i = 0; i < txn1.logs.length; i++){
        let log = txn1.logs[i];
        //console.log(log);
        applicationId1 = log.args.applicationId;
        assert.isTrue(log.event == "LogMembershipApplied", "Expected LogMembershipApplied event to be triggerred but found " + log.event + " event instead.");
      }

      let txn2 = await membershipInstance.applyForMembership("Barnaby", "Joyce", "https://gov.au/bjoyce", "https://linkedin.com/bjoyce", "https://twitter.com/bjoyce", {from : account5, value : web3.toWei(0.1, "ether")});
      //console.log(txn2);
      for(let i = 0; i < txn2.logs.length; i++){
        let log = txn2.logs[i];
        //console.log(log);
        applicationId2 = log.args.applicationId;
        assert.isTrue(log.event == "LogMembershipApplied", "Expected LogMembershipApplied event to be triggerred but found " + log.event + " event instead.");
      }

      let txn3 = await membershipInstance.applyForMembership("Tony", "Abbott", "https://gov.au/tabbott", "https://linkedin.com/tabbott", "https://twitter.com/tabbott", {from : account6, value : web3.toWei(0.01, "ether")});
      //console.log(txn3);
      for(let i = 0; i < txn3.logs.length; i++){
        let log = txn3.logs[i];
        //console.log(log);
        applicationId3 = log.args.applicationId;
        assert.isTrue(log.event == "LogMembershipApplied", "Expected LogMembershipApplied event to be triggerred but found " + log.event + " event instead.");
      }

      let errorMsg1 = "The expected application id was " + 1 + " but received id was " + applicationId1;
      let errorMsg2 = "The expected application id was " + 2 + " but received id was " + applicationId2;
      let errorMsg3 = "The expected application id was " + 3 + " but received id was " + applicationId3;

      assert.equal(applicationId1, 1, errorMsg1);
      assert.equal(applicationId2, 2, errorMsg2);
      assert.equal(applicationId3, 3, errorMsg3);

      var pendingApplicant1 = await membershipInstance.getPendingApplicationDetails.call(1);
      assert.equal(pendingApplicant1[0], 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544, "Expected member addrs to be 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544 but actual is " + pendingApplicant1[0]);
      assert.equal(pendingApplicant1[1], "Malcolm", "Expected first name to be Malcolm but actual is " + pendingApplicant1[1]);
      assert.equal(pendingApplicant1[2], "Turnbull", "Expected last name to be Turnbull but actual is " + pendingApplicant1[2]);
      assert.equal(pendingApplicant1[3], "https://gov.au/mturnbull", "Expected company URL to be https://gov.au/mturnbull but actual is " + pendingApplicant1[3]);
      assert.equal(pendingApplicant1[4], "https://linkedin.com/mturnbull", "Expected LinkedIn URL to be https://linkedin.com/mturnbull but actual is " + pendingApplicant1[4]);
      assert.equal(pendingApplicant1[5], "https://twitter.com/mturnbull", "Expected Twitter URL to be https://twitter.com/mturnbull but actual is " + pendingApplicant1[5]);

      var pendingApplicant2 = await membershipInstance.getPendingApplicationDetails.call(2);
      assert.equal(pendingApplicant2[0], "0x0d1d4e623d10f9fba5db95830f7d3839406c6af2", "Expected member addrs to be 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2 but actual is " + pendingApplicant2[0]);
      assert.equal(pendingApplicant2[1], "Barnaby", "Expected first name to be Barnaby but actual is " + pendingApplicant2[1]);
      assert.equal(pendingApplicant2[2], "Joyce", "Expected last name to be Joyce but actual is " + pendingApplicant2[2]);
      assert.equal(pendingApplicant2[3], "https://gov.au/bjoyce", "Expected company URL to be https://gov.au/bjoyce but actual is " + pendingApplicant2[3]);
      assert.equal(pendingApplicant2[4], "https://linkedin.com/bjoyce", "Expected LinkedIn URL to be https://linkedin.com/bjoyce but actual is " + pendingApplicant2[4]);
      assert.equal(pendingApplicant2[5], "https://twitter.com/bjoyce", "Expected Twitter URL to be https://twitter.com/bjoyce but actual is " + pendingApplicant2[5]);

      var pendingApplicant3 = await membershipInstance.getPendingApplicationDetails.call(3);
      assert.equal(pendingApplicant3[0], "0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e", "Expected member addrs to be 0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e but actual is " + pendingApplicant3[0]);
      assert.equal(pendingApplicant3[1], "Tony", "Expected first name to be Tony but actual is " + pendingApplicant3[1]);
      assert.equal(pendingApplicant3[2], "Abbott", "Expected last name to be Abbott but actual is " + pendingApplicant3[2]);
      assert.equal(pendingApplicant3[3], "https://gov.au/tabbott", "Expected company URL to be https://gov.au/tabbott but actual is " + pendingApplicant3[3]);
      assert.equal(pendingApplicant3[4], "https://linkedin.com/tabbott", "Expected LinkedIn URL to be https://linkedin.com/tabbott but actual is " + pendingApplicant3[4]);
      assert.equal(pendingApplicant3[5], "https://twitter.com/tabbott", "Expected Twitter URL to be https://twitter.com/tabbott but actual is " + pendingApplicant3[5]);

  }catch(error){
    console.log(error);
  }
  });

  it("should confirm membership for application id when invoked by owner", async () => {
    let membershipInstance = await Membership.deployed();
    var applicationId, memberId, applicationId2, memberId2;
    try{
      let txn = await membershipInstance.addMembership(2, {from : account2});
      for(let i = 0; i < txn.logs.length; i++){
        let log = txn.logs[i];
        // console.log(log);
        applicationId = log.args.applicationId;
        memberId = log.args.memberId;
        assert.isTrue(log.event == "LogMembershipAdded", "Expected LogMembershipAdded event to be triggerred but found " + log.event + " event instead.");
      }
      var member1 = await membershipInstance.getMemberDetails.call(1);
      assert.equal(member1[0], "0x0d1d4e623d10f9fba5db95830f7d3839406c6af2", "Expected member addrs to be 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2 but actual is " + member1[0]);
      assert.equal(member1[1], "Barnaby", "Expected first name to be Barnaby but actual is " + member1[1]);
      assert.equal(member1[2], "Joyce", "Expected last name to be Joyce but actual is " + member1[2]);
      assert.equal(member1[3], "https://gov.au/bjoyce", "Expected company URL to be https://gov.au/bjoyce but actual is " + member1[3]);
      assert.equal(member1[4], "https://linkedin.com/bjoyce", "Expected LinkedIn URL to be https://linkedin.com/bjoyce but actual is " + member1[4]);
      assert.equal(member1[5], "https://twitter.com/bjoyce", "Expected Twitter URL to be https://twitter.com/bjoyce but actual is " + member1[5]);

      let txn1 = await membershipInstance.addMembership(1, {from : account2});
      for(let i = 0; i < txn1.logs.length; i++){
        let log1 = txn1.logs[i];
        // console.log(log1);
        applicationId2 = log1.args.applicationId;
        memberId2 = log1.args.memberId;
        assert.isTrue(log1.event == "LogMembershipAdded", "Expected LogMembershipAdded event to be triggerred but found " + log1.event + " event instead.");
      }
      var member2 = await membershipInstance.getMemberDetails.call(2);
      assert.equal(member2[0], 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544, "Expected member addrs to be 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544 but actual is " + member2[0]);
      assert.equal(member2[1], "Malcolm", "Expected first name to be Malcolm but actual is " + member2[1]);
      assert.equal(member2[2], "Turnbull", "Expected last name to be Turnbull but actual is " + member2[2]);
      assert.equal(member2[3], "https://gov.au/mturnbull", "Expected company URL to be https://gov.au/mturnbull but actual is " + member2[3]);
      assert.equal(member2[4], "https://linkedin.com/mturnbull", "Expected LinkedIn URL to be https://linkedin.com/mturnbull but actual is " + member2[4]);
      assert.equal(member2[5], "https://twitter.com/mturnbull", "Expected Twitter URL to be https://twitter.com/mturnbull but actual is " + member2[5]);

    }catch(error){
      console.log(error);
    }
    let errorMsg1 = "The expected application id was " + 2 + " but received id was " + applicationId;
    let errorMsg2 = "The expected member id was " + 1 + " but received id was " + memberId;

    assert.equal(applicationId, 2, errorMsg1);
    assert.equal(memberId, 1, errorMsg2);

    let errorMsg3 = "The expected application id was " + 1 + " but received id was " + applicationId2;
    let errorMsg4 = "The expected member id was " + 2 + " but received id was " + memberId2;

    assert.equal(applicationId2, 1, errorMsg3);
    assert.equal(memberId2, 2, errorMsg4);
  });

  it("should not confirm membership for application id when invoked by non-owner / unknown account", async () => {
    let membershipInstance = await Membership.deployed();
    let applicationId, memberId;
    try{
      let txn = await membershipInstance.addMembership(2, {from : account3});
    }catch(error){
      //console.log("Error", error);
      assert.isTrue(error.name == "StatusError", "Transaction did not fail when attempting to confirm membership by a non-owner, status is not error");
      assert.isTrue(error.receipt.status == "0x00", "Transaction did not fail when attempting to confirm membership by a non-owner, status is not failure");
    }
  });

  it("should revoke membership for member id when invoked by owner", async () => {
    let membershipInstance = await Membership.deployed();
    let memberId;
    try{
      let txn = await membershipInstance.revokeMembership(1, {from : account2});
      // console.log(txn);
      for(let i = 0; i < txn.logs.length; i++){
        let log = txn.logs[i];
        // console.log(log);
        memberId = log.args.memberId;
        assert.isTrue(log.event == "LogMembershipRevoked", "Expected LogMembershipRevoked event to be triggerred but found " + log.event + " event instead.");
      }
    }catch(error){
      console.log("Error", error);
    }
    let errorMsg = "The expected member id was " + 1 + " but received id was " + memberId;
    assert.isTrue(memberId == 1, errorMsg);
  });

  it("should not revoke membership for member id when invoked by non-owner / unknown account", async () => {
    let membershipInstance = await Membership.deployed();
    let memberId;
    try{
      let txn = await membershipInstance.revokeMembership(1, {from : account1});
    }catch(error){
      //console.log("Error", error);
      assert.isTrue(error.name == "StatusError", "Transaction did not fail when attempting to revoke membership by a non-owner, status is not error");
      assert.isTrue(error.receipt.status == "0x00", "Transaction did not fail when attempting to revoke membership by a non-owner, status is not failure");
    }
  });

});

contract('Membership - tests for funds transfer', async (accounts) => {

  const account1 = accounts[0]; //0x627306090abaB3A6e1400e9345bC60c78a8BEf57
  const account2 = accounts[1]; //0xf17f52151EbEF6C7334FAD080c5704D77216b732
  const account3 = accounts[2]; //0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef

  before(async () => {
    // runs before all tests in this block
    let membershipInstance = await Membership.deployed();
    await membershipInstance.applyForMembership("Malcolm", "Turnbull", "https://gov.au/mturnbull", "https://linkedin.com/mturnbull", "https://twitter.com/mturnbull", {from : account2, value : web3.toWei(1, "ether")});
    await membershipInstance.applyForMembership("Barnaby", "Joyce", "https://gov.au/bjoyce", "https://linkedin.com/bjoyce", "https://twitter.com/bjoyce", {from : account3, value : web3.toWei(0.1, "ether")});
  });

  it("should not transfer funds to provided address when called by non-owner / unknown address", async () => {
    let membershipInstance = await Membership.deployed();
    try{
      await membershipInstance.transferFunds(account3, {from : account3});
    }catch(error){
      //console.log(error);
      assert.isTrue(error.name == "StatusError", "Transaction did not fail when attempting to transfer funds by a non-owner, status is not error");
      assert.isTrue(error.receipt.status == "0x00", "Transaction did not fail when attempting to transfer funds by a non-owner, status is not failure");
      let currentContractBalance = web3.eth.getBalance(membershipInstance.address);
      assert.isTrue(currentContractBalance.toNumber() > 0, "Contract balance is zero");;
    }
  });

  it("should transfer funds to provided address when called by owner", async () => {
    let membershipInstance = await Membership.deployed();
    let previousContractBalance = web3.eth.getBalance(membershipInstance.address);
    let previousAccountBalance = web3.eth.getBalance(account3);
    try{
        let txn = await membershipInstance.transferFunds(account3, {from : account1});
        for(let i = 0; i < txn.logs.length; i++) {
          let log = txn.logs[i];
          assert.isTrue(log.event == "LogFundsTransfer", "Expected LogFundsTransfer event to be triggerred but found " + log.event + " event instead.");
        }
    } catch(error){
        console.log(error);
    }
    let currentContractBalance = web3.eth.getBalance(membershipInstance.address);
    let currentAccountBalance = web3.eth.getBalance(account3);

    assert.isTrue(currentContractBalance.toNumber() == 0, "Contract balance is not zero after transfer");
    assert.isTrue(currentAccountBalance.toNumber() == (previousAccountBalance.toNumber() + previousContractBalance.toNumber()), "Account balance is incorrect after transfer");
  });

  contract('Membership - tests for selfdestruct', async (accounts) => {

    const account1 = accounts[0]; //0x627306090abaB3A6e1400e9345bC60c78a8BEf57
    const account2 = accounts[1]; //0xf17f52151EbEF6C7334FAD080c5704D77216b732
    const account3 = accounts[2]; //0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef

    before(async () => {
      // runs before all tests in this block
      let membershipInstance = await Membership.deployed();
      await membershipInstance.applyForMembership("Malcolm", "Turnbull", "https://gov.au/mturnbull", "https://linkedin.com/mturnbull", "https://twitter.com/mturnbull", {from : account2, value : web3.toWei(1, "ether")});
      await membershipInstance.applyForMembership("Barnaby", "Joyce", "https://gov.au/bjoyce", "https://linkedin.com/bjoyce", "https://twitter.com/bjoyce", {from : account3, value : web3.toWei(0.1, "ether")});
    });

    it("should not selfdestruct called by non-owner / unknown address", async () => {
      let membershipInstance = await Membership.deployed();
      try{
        await membershipInstance.destroy({from : account3});
      }catch(error){
        //console.log(error);
        assert.isTrue(error.name == "StatusError", "Transaction did not fail when attempting to transfer funds by a non-owner, status is not error");
        assert.isTrue(error.receipt.status == "0x00", "Transaction did not fail when attempting to transfer funds by a non-owner, status is not failure");
      }
    });

    it("should selfdestruct called by owner", async () => {
      let membershipInstance = await Membership.deployed();
      let previousOwnerBalance, previousContractBalance, currentContractBalance, currentOwnerBalance;
      try{
        previousOwnerBalance =  web3.fromWei(web3.eth.getBalance(account1), "ether");
        previousContractBalance = web3.fromWei(web3.eth.getBalance(membershipInstance.address), "ether");
        try{
            let txn = await membershipInstance.destroy({from : account1});
            for(let i = 0; i < txn.logs.length; i++) {
              let log = txn.logs[i];
              assert.isTrue(log.event == "LogMembershipContractSelfDestruct", "Expected LogMembershipContractSelfDestruct event to be triggerred but found " + log.event + " event instead.");
            }
        } catch(error){
            console.log(error);
        }
        currentContractBalance = web3.fromWei(web3.eth.getBalance(membershipInstance.address), "ether");
        currentOwnerBalance = web3.fromWei(web3.eth.getBalance(account1), "ether");
      }catch(error){
        console.log(error);
      }

      assert.isTrue(currentContractBalance.toNumber() == 0, "Contract balance is not zero after selfdestruct");
      // Can't verify this because gas is spent by owner to execute the txn
      // assert.isTrue(currentOwnerBalance.toNumber() == (sum), "Owner account balance is incorrect after selfdestruct");
    });

  });
});
