const SafeMath = artifacts.require("SafeMath");
const Verificator = artifacts.require("Verificator");
const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest1 = artifacts.require("MockSmartContractTest1");
const MockSmartContractTest2 = artifacts.require("MockSmartContractTest2");
const MockSmartContractTest3 = artifacts.require("MockSmartContractTest3");
const MockSmartContractTest4 = artifacts.require("MockSmartContractTest4");
const MockSmartContractTest5 = artifacts.require("MockSmartContractTest5");
const MockSmartContractTest6 = artifacts.require("MockSmartContractTest6");
const MockSmartContractTest7 = artifacts.require("MockSmartContractTest7");

module.exports = function (deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, Verificator);
    deployer.deploy(Verificator);
    deployer.deploy(MockSmartContractToVerify).then(function () {
        // MockSmartContract.address and Verificator.address is an argument
        return deployer.deploy(SmartContractVerificator, MockSmartContractToVerify.address, Verificator.address)
    });
    // smart contract test
    deployer.deploy(MockSmartContractTest1);
    deployer.deploy(MockSmartContractTest2);
    deployer.deploy(MockSmartContractTest3);
    deployer.deploy(MockSmartContractTest4);
    deployer.deploy(MockSmartContractTest5);
    deployer.deploy(MockSmartContractTest6);
    deployer.deploy(MockSmartContractTest7);
};
