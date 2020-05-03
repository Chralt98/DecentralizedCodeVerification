const SafeMath = artifacts.require("SafeMath");
const Verificator = artifacts.require("Verificator");
const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest = artifacts.require("MockSmartContractTest");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Verificator);
  deployer.deploy(Verificator);
  // MockSmartContract.address is an argument
  deployer.deploy(MockSmartContractToVerify).then(function(){
    return deployer.deploy(SmartContractVerificator, MockSmartContractToVerify.address)});
  // smart contract test
  deployer.deploy(MockSmartContractTest);
};
