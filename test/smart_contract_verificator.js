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

});
