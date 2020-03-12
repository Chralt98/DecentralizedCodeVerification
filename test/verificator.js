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
    const notVerifiedProgrammer = accounts[2];
    // console.log(verificatorInstance.address);
    await this.verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
      const isProgrammerVerified = await this.verificatorInstance.isProgrammerVerified.call(programmer);
      const programmerPoints = (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber();
      const isProgrammerAllowedToTest = (await this.verificatorInstance.isProgrammerAllowedToTest.call(programmer));
      assert(isProgrammerAllowedToTest === true, "Added verified programmer should be allowed to test.");
      assert(isProgrammerVerified === true, "First account is not verified.");
      assert.equal(programmerPoints, 10, "Initial account got not the initial 10 points.");
      assert.equal(await this.verificatorInstance.isProgrammerVerified.call(notVerifiedProgrammer), false, "Not added programmer should not be verified.");
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

  it('should add a smart contract verificator', async () => {
    const smartContractVerificator = accounts[5];
    await this.verificatorInstance.addSmartContractVerificator(smartContractVerificator).then(async () => {
      assert.equal(await this.verificatorInstance.isSmartContractVerificator.call(smartContractVerificator), true, "Smart contract should be verificated.");
    });
    await this.verificatorInstance.deleteSmartContractVerificator(smartContractVerificator).then(async () => {
      assert.equal(await this.verificatorInstance.isSmartContractVerificator.call(smartContractVerificator), false, "Smart contract should not be verificated.");
    });
  });

  it('should add a smart contract verificator and verified programmer points', async () => {
    const smartContractVerificator = accounts[5];
    const bob = accounts[2];
    const programmer = accounts[1];
    await this.verificatorInstance.addSmartContractVerificator(smartContractVerificator).then(async () => {
      assert.equal(await this.verificatorInstance.isSmartContractVerificator.call(smartContractVerificator), true, "Smart contract should be verificated.");
      var programmerPointsBefore = (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber();
      await this.verificatorInstance.addProgrammerPoints(programmer, 2, {from: smartContractVerificator});
      assert((await this.verificatorInstance.isProgrammerAllowedToTest.call(programmer)) === true, "Added verified programmer should be allowed to test.");
      assert.equal((await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), programmerPointsBefore + 2, "Verified programmer should have two more points.");
      try {
          await this.verificatorInstance.addProgrammerPoints(programmer, {from:bob});
      } catch (e) {
          var err = e;
      }
      assert.isOk(err instanceof Error, "Transaction was not reverted with an invalid address.");
    });
  });
  // every integration test in here sees the variables edited above
});
