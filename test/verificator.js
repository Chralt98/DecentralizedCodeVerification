const Verificator = artifacts.require("Verificator");
// accounts = web3.eth.getAccounts();

contract('Verificator', (accounts) => {
  var verificatorInstance;

  before( async () => {
        this.verificatorInstance = await Verificator.deployed();
  });

  it('should add an account as a verified programmer', async () => {
    // accounts[0] is the owner of the verificator instance
    const programmer = accounts[1];
    // console.log(verificatorInstance.address);
    await this.verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
      const isProgrammerVerified = await this.verificatorInstance.isProgrammerVerified.call(programmer);
      const programmerPoints = (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber();
      assert(isProgrammerVerified === true, "First account is not verified.");
      assert.equal(programmerPoints, 10, "Initial account got not the initial 10 points.");
    });

  });
  it('should revert the transaction of addVerifiedProgrammer when an invalid address calls it', async () => {
    // here is the owner of the smart contract which deployed it
    const creatorAddress = accounts[0];
    const bob = accounts[1];
    const alice = accounts[2];

    try {
        await this.verificatorInstance.addVerifiedProgrammer(alice, {from:bob});
    } catch (e) {
        var err = e;
    }
    assert.isOk(err instanceof Error, "Transaction was not reverted with an invalid address.");
  });
  // every integration test in here sees the variables edited above
});
