pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Example_remix_test.sol file!!!
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
// IMPORTANT: compiler does not know remix_accounts.sol, but solidity unit testing module accepts it
import "remix_accounts.sol";
// Verificator.sol file should be on the same directory level as this file
import "../contracts/Verificator.sol";

contract VerificatorTest {
  Verificator verificator;
  address verificatorOwner;
  address bob;
  address alice;

  function beforeAll() public {
    verificatorOwner = getAccount(0);
    checkModifier(msg.sender, verificatorOwner);
    verificator = new Verificator();
    bob =  getAccount(1);
    alice = getAccount(2);
  }

  function getAccount(uint _index) public returns(address){
    return TestsAccounts.getAccount(_index);
  }

  function checkModifier(address _sender, address _legitimately) public {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  // function name has to start with "test"
  function testAddingVerifiedProgrammer() public {
    checkModifier(msg.sender, verificatorOwner);
    verificator.addVerifiedProgrammer(alice);
    checkAddedVerifiedProgrammer();
  }

  // this function could be called by every address, but after adding alice as owner
  function checkAddedVerifiedProgrammer() public {
    uint expectedProgrammerPoints = 10;
    Assert.ok(verificator.isProgrammerVerified(alice), "Programmer should be verified.");
    Assert.ok(verificator.isProgrammerAllowedToTest(alice), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(alice), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");
  }
}
