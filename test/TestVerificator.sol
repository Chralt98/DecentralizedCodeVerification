pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Verificator.sol";

// contract name has to start with "Test"
contract TestVerificator {
  // Truffle will send the TestVerificator contract one Ether after deploying the contract.
  uint public initialBalance = 14 ether;

  function beforeEach() {
    // runs before each test function
  }

  function beforeAll() {
    // runs before all test functions
  }

  function afterEach() {

  }

  function afterAll() {

  }

  // function name has to start with "test"
  function testAddingVerifiedProgrammer() public {
    address verificatorOwner = DeployedAddresses.Verificator();
    Verificator verificator = Verificator(verificatorOwner);
    // could send ether to the contract with verificator.send(14 ether);
    bool expected = true;
    address verifiedProgrammer = 0x389247234723349;
    verificator.addVerifiedProgrammer(verifiedProgrammer);
    uint expectedProgrammerPoints = 10;
    Assert.equal(verificator.isProgrammerVerified(verifiedProgrammer), expected, "Programmer should be verified.");
    Assert.equal(verificator.isProgrammerAllowedToTest(verifiedProgrammer), expected, "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(verifiedProgrammer), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");
    // Assert.isFalse(69==14, "69 equals 14 is false.");
    // Assert.isTrue(1==1, "1 equals 1 is true.");
  }

}
