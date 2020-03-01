const SafeMath = artifacts.require("SafeMath");
const Verificator = artifacts.require("Verificator");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Verificator);
  deployer.deploy(Verificator);
};
