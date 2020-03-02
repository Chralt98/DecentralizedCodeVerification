pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Example_remix_test.sol file!!!
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
// IMPORTANT: compiler does not know remix_accounts.sol, but solidity unit testing module accepts it
import "remix_accounts.sol";
// Verificator.sol file should be on the same directory level as this file
import "./Verificator.sol";

contract VerificatorTest {
  Verificator verificator;
  address verificatorOwner;
  address bob;
  address alice;

  function beforeAll() {
    Assert.equal(msg.sender, TestsAccounts.getAccount(0), "Only the owner can call beforeAll.");
    verificator = new Verificator();
    verificatorOwner = TestsAccounts.getAccount(0);
    bob =  TestsAccounts.getAccount(1);
    alice = TestsAccounts.getAccount(2);
  }

  // function name has to start with "test"
  function testAddingVerifiedProgrammer() public {
    Assert.equal(msg.sender, TestsAccounts.getAccount(0), "Only the owner can call testAddingVerifiedProgrammer.");
    verificator.addVerifiedProgrammer(alice);
    checkAddedVerifiedProgrammer();
  }

  // this function could be called by every address, but after adding alice as owner
  function checkAddedVerifiedProgrammer() public {
    uint expectedProgrammerPoints = 10;
    Assert.isTrue(verificator.isProgrammerVerified(alice), "Programmer should be verified.");
    Assert.isTrue(verificator.isProgrammerAllowedToTest(alice), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(alice), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");
  }
}
