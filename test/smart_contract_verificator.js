const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest = artifacts.require("MockSmartContractTest");

contract('SmartContractVerificator', (accounts) => {
  var verificatorInstance;
  var smartContractToVerify;
  var smartContractTest;

  before( async () => {
        this.verificatorInstance = await SmartContractVerificator.deployed();
        this.smartContractToVerify = await MockSmartContractToVerify.deployed();
        this.smartContractTest = await MockSmartContractTest.deployed();
  });

  it('should check smart contract to verify', async () => {
    assert.equal(await this.verificatorInstance.getSmartContractToVerify(), this.smartContractToVerify.address, "Smart contract addresses should be equal.");
    assert(await this.verificatorInstance.isSmartContractVerified() === false, "Smart contract should not be verified.");
    assert(await this.verificatorInstance.getVerificationState() === "ACTIVE", "Smart contract should be active.");
  });

  it('should send smart contract test', async () => {
    const programmer = accounts[2];
    await this.verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
      await this.verificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: programmer}).then(async () => {
        assert.isOk(this.verificatorInstance.isTesterSpace(), "Tester space shouldn't be full");
        // TODO check if test is added:
        console.log(this.verificatorInstance.getTests({from: programmer}));
        assert.isOk(this.verificatorInstance.getTests({from: programmer}), "Test should be added.");
      });
    });
  });

  it('should increase reward stake', async () => {
    // test reward stake wallet
    const payer = accounts[1];
    await this.verificatorInstance.getRewardAmount().then(async (balanceBefore) => {
      await this.verificatorInstance.increaseRewardStake({from: payer, value: 1e18}).then(async () => {
        assert.equal(web3.utils.toBN(1e18 + balanceBefore), web3.utils.toBN(await this.verificatorInstance.getRewardAmount()), "Should have 1 ether more now.");
      });
    });
  });
});
