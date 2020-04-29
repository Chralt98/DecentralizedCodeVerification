const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const SmartContractToVerify = artifacts.require("Verificator");

contract('SmartContractVerificator', (accounts) => {
  var verificatorInstance;
  var smartContractToVerify;

  before( async () => {
        this.verificatorInstance = await SmartContractVerificator.deployed();
        this.smartContractToVerify = await SmartContractToVerify.deployed();
  });

  it('should check smart contract to verify', async () => {
    assert.equal(await this.verificatorInstance.getSmartContractToVerify(), this.smartContractToVerify.address, "Smart contract addresses should be equal.");
    assert(await this.verificatorInstance.isSmartContractVerified() === false, "Smart contract should not be verified.");
  });

  it('should add wei offer', async () => {
    const programmer = accounts[2];
    await this.verificatorInstance.addVerifiedProgrammer(programmer);
    await this.verificatorInstance.sendBestWeiOffer(123456, {from: programmer}).then(async () => {
      try {
          // cause error because not the smart smartContractVerificator calls addProgrammerPoints
          await this.verificatorInstance.sendBestWeiOffer(654321, {from: programmer});
      } catch (e) {
          var err = e;
      }
      assert.isOk(err instanceof Error, "Transaction was not reverted with a doubled offer.");
      console.log(await this.verificatorInstance.getBestWeiOffers());
      // in solidity code should use fixed bytes32[10] array as wei offers or delete it completely if it is not so required
      assert.equal(await this.verificatorInstance.getBestWeiOffers()[0], 123456, "Best wei offer should be set.");
    });
  });

  it('should increase reward stake', async () => {
    // test reward stake wallet
  });
});
