pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Verificator.sol";

// contract name has to start with "Test"
contract TestTruffleVerificator {
  // Truffle will send the TestVerificator contract one Ether after deploying the contract.
  // uint public initialBalance = 1414 ether;
  // get the deploy owner => Verificator verificator = new Verificator(DeployedAddresses.Verificator());
  // could send ether to the contract with verificator.send(14 ether);

  function beforeAll() public {}
  function beforeEach() public {}
  function afterEach() public {}
  function afterAll() public {}

  // function name has to start with "test"
  function testAddingVerifiedProgrammer() public {
    Verificator verificator = new Verificator();
    address alice = 0xfc9757794D38f6B462277a1e26fC82292F30D6dC;
    verificator.addVerifiedProgrammer(alice);
    uint expectedProgrammerPoints = 10;
    Assert.isTrue(verificator.isProgrammerVerified(alice), "Programmer should be verified.");
    Assert.isTrue(verificator.isProgrammerAllowedToTest(alice), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(alice), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");
  }
}
