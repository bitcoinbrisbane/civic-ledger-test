// Test for owned contract

var Owned = artifacts.require("./Owned.sol");

contract('Owned', async (accounts) => {

  const account1 = accounts[0]; //0x627306090abaB3A6e1400e9345bC60c78a8BEf57
  const account2 = accounts[1]; //0xf17f52151EbEF6C7334FAD080c5704D77216b732
  const account3 = accounts[2]; //0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef

  // Before this test, the contract owner is account1
  // After this test, the contract owner is account1
  it("should instantiate owner as the contract creator", async () => {
    let ownedInstance = await Owned.deployed();
    let owner = await ownedInstance.owner.call();
    let errorMsg = "Expected contract creator(" + account1 + ") to be the owner but got " + owner + " as the owner";
    assert.equal(owner, account1, errorMsg);
  });

  // Before this test, the contract owner is account1
  // After this test, the contract owner is account2
  it("should allow owner to transfer ownership", async () => {
    let ownedInstance = await Owned.deployed();
    let previousOwner = await ownedInstance.owner.call();
    await ownedInstance.transferOwnership(account2, {from : account1});
    let newOwner = await ownedInstance.owner.call();
    let errorMsg = "Expected owner" + account2 + " , actual owner " + newOwner;
    assert.equal(newOwner, account2, errorMsg);
  });

  // Before this test, the contract owner is account2
  // After this test, the contract owner is account2
  it("should not allow unknown account to transfer ownership", async () => {
    let ownedInstance = await Owned.deployed();
    let previousOwner = await ownedInstance.owner.call();
    try{
      await ownedInstance.transferOwnership(account3, {from : account1});
    } catch(error){
      let newOwner = await ownedInstance.owner.call();
      let errorMsg = "The ownership transfer should fail if not initiated by contract owner";
      assert.equal(newOwner, account2, errorMsg);
    }
  });

});
