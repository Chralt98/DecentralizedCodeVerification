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

  it('should increase reward stake', async () => {
    // test reward stake wallet
    const payer = accounts[1];
    let balanceBefore = await web3.eth.getBalance(await this.verificatorInstance.getRewardWalletAddress());
    await this.verificatorInstance.increaseRewardStake({from: payer, value: 1000000000000000000}).then(async () => {
      assert.equal(Number(balanceBefore) + 1000000000000000000, Number(await web3.eth.getBalance(await this.verificatorInstance.getRewardWalletAddress())), "Should have 1 ether more now.");
    });
  });
});
