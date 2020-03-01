const Verificator = artifacts.require("Verificator");
// accounts = web3.eth.getAccounts();
contract('Verificator', (accounts) => {
  it('should add an account as a verified programmer', async () => {
    // accounts[0] is the owner of the verificator instance
    const verificatorInstance = await Verificator.deployed();
    const programmer = accounts[1];
    // console.log(verificatorInstance.address);
    await verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
      const isProgrammerVerified = await verificatorInstance.isProgrammerVerified.call(programmer);
      const programmerPoints = (await verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber();
      assert(isProgrammerVerified === true, "First account is not verified.");
      assert.equal(programmerPoints, 10, "Initial account got not the initial 10 points.");
    });

  });
  it('should revert the transaction of addVerifiedProgrammer when an invalid address calls it', async () => {
    const verificatorInstance = await Verificator.deployed();
    // here is the owner of the smart contract which deployed it
    const creatorAddress = accounts[0];
    const bob = accounts[1];
    const alice = accounts[2];

    return Verificator.deployed()
      .then(instance => {
        // bob is not allowed to call addVerifiedProgrammer() to add alice
        return instance.addVerifiedProgrammer(alice, {from: bob});
      })
      // triggers .then() only when the above code works
      .then(result => {
        // bob is not allowed to add alice as verified programmer => fails
        assert.fail();
      })
      .catch(error => {
        // if the above code (fail) runs then the catched error is this assert.fail()
        // if it is assert.fail() then bob added alice as verified programmer
        assert.notEqual(error.message, "assert.fail()", "Transaction was not reverted with an invalid address.");
      });
  });
  // every integration test in here sees the variables edited above
});
