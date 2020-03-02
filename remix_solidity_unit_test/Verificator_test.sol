pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Example_remix_test.sol file!!!
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
// IMPORTANT: compiler does not know remix_accounts.sol, but solidity unit testing module accepts it
import "remix_accounts.sol";
// Verificator.sol file should be on the same directory level as this file
import "../contracts/Verificator.sol";

contract MockSmartContractVerificator is Verificator {
  constructor() public {}
}

contract VerificatorTest {
  Verificator verificator;
  address verificatorOwner;

  /// #sender: account-0
  /// #value: 1000
  function beforeAll() public {
    verificatorOwner = TestsAccounts.getAccount(0);
    compareModifier(msg.sender, verificatorOwner);
    verificator = new Verificator();
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  /// #sender: account-0
  /// #value: 1000
  function checkAddingVerifiedProgrammer() public {
    compareModifier(msg.sender, verificatorOwner);
    address alice = TestsAccounts.getAccount(1);
    verificator.addVerifiedProgrammer(alice);
    uint expectedProgrammerPoints = 10;
    Assert.ok(verificator.isProgrammerVerified(alice), "Programmer should be verified.");
    Assert.ok(verificator.isProgrammerAllowedToTest(alice), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(alice), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");

    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encode("addVerifiedProgrammer, [alice]"));
    Assert.equal(success, false, "Transaction should revert if address is already verified.");
  }

  /// #sender: account-2
  /// #value: 1000
  function checkAddingVerifiedProgrammerNotLegitimate() public returns (bool) {
    // bob is not the owner of the verificator
    compareModifier(msg.sender, TestsAccounts.getAccount(2));
    address alice = TestsAccounts.getAccount(1);
    // check if transacton is correctly reverted
    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encode("addVerifiedProgrammer, [alice]"));
    return Assert.equal(success, false, "Transaction was not reverted with an invalid address.");
  }

  /// #sender: account-0
  /// #value: 1000
  function checkAddingSmartContractVerificator() public {
    compareModifier(msg.sender, verificatorOwner);
    MockSmartContractVerificator mockSmartContractVerificator = new MockSmartContractVerificator();
    verificator.addSmartContractVerificator(address(mockSmartContractVerificator));

    address alice = TestsAccounts.getAccount(1);
    verificator.addVerifiedProgrammer(alice);
    uint8 positivePoints = 2;

    // should only get called by mockSmartContractVerificator
    (bool success, bytes memory data) = address(mockSmartContractVerificator).call.gas(40000).value(0)(abi.encode("addProgrammerPoints, [alice, positivePoints]"));
    Assert.equal(success, true, "Transaction should not revert if programmer is verified.");

    /*
    address bob = TestsAccounts.getAccount(2);

    // fails if the caller is no smart contract verificator
    (success, data) = address(bob).call.gas(40000).value(0)(abi.encode("addProgrammerPoints, [alice, positivePoints]"));
    Assert.equal(success, false, "Transaction should revert if the caller is not a smart contract verificator.");

    // fails if the programmer address is not in the verified programmer list
    (success, data) = address(mockSmartContractVerificator).call.gas(40000).value(0)(abi.encode("addProgrammerPoints, [bob, positivePoints]"));
    Assert.equal(success, false, "Transaction should revert if the programmer is not verified.");
    */
  }
}
