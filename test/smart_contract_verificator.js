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
    assert(await this.verificatorInstance.getVerificationState() === "ACTIVE", "Smart contract should be active.");
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
