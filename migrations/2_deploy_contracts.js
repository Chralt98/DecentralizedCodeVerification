const SafeMath = artifacts.require("SafeMath");
const Verificator = artifacts.require("Verificator");
const SmartContractVerificator = artifacts.require("SmartContractVerificator");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Verificator);
  // Verificator is an argument
  deployer.deploy(Verificator).then(function(){
    return deployer.deploy(SmartContractVerificator, Verificator.address)});
};
