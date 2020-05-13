const SafeMath = artifacts.require("SafeMath");
const Verificator = artifacts.require("Verificator");
const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest = artifacts.require("MockSmartContractTest");

module.exports = function (deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, Verificator);
    deployer.deploy(Verificator).then(function () {
        deployer.deploy(MockSmartContractToVerify).then(function () {
            // MockSmartContract.address and Verificator.address is an argument
            return deployer.deploy(SmartContractVerificator, MockSmartContractToVerify.address)
        });
    });

    // smart contract test
    deployer.deploy(MockSmartContractTest);
};
