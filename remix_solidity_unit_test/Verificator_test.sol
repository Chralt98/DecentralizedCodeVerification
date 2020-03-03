pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Example_remix_test.sol file!!!
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
// IMPORTANT: compiler does not know remix_accounts.sol, but solidity unit testing module accepts it
import "remix_accounts.sol";
// Verificator.sol file should be on the same directory level as this file
import "../contracts/Verificator.sol";

contract VerificatorTest {
  address verificatorOwner;
  Verificator ownerVerificator;

  /// #sender: account-0
  /// #value: 100
  function beforeAll() public {
    verificatorOwner = TestsAccounts.getAccount(0);
    compareModifier(msg.sender, verificatorOwner);
    ownerVerificator = new Verificator();
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  /// #sender: account-0
  /// #value: 100
  function checkAddingVerifiedProgrammer() public {
    compareModifier(msg.sender, verificatorOwner);

    address alice = TestsAccounts.getAccount(1);
    ownerVerificator.addVerifiedProgrammer(alice);
    uint expectedProgrammerPoints = 10;
    Assert.ok(ownerVerificator.isProgrammerVerified(alice), "Programmer should be verified.");
    Assert.ok(ownerVerificator.isProgrammerAllowedToTest(alice), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(ownerVerificator.getVerifiedProgrammerPoints(alice), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");

    (bool success, bytes memory data) = address(ownerVerificator).call.gas(40000).value(0)(abi.encodeWithSignature("addVerifiedProgrammer(address)", alice));
    Assert.equal(success, false, "Transaction should revert if address is already verified.");
  }

  /// #sender: account-2
  function checkAddingVerifiedProgrammerNotLegitimate() public {
    address bob = TestsAccounts.getAccount(2);
    compareModifier(msg.sender, bob);
    // bob tries to verify himself which should be reverted correctly
    (bool success, bytes memory data) = address(ownerVerificator).call.gas(40000).value(0)(abi.encodeWithSignature("addVerifiedProgrammer(address)", bob));
    Assert.equal(success, false, "Transaction should revert if address is not legitimate to add a verified programmer.");

    Assert.equal(ownerVerificator.isProgrammerVerified(bob), false, "Programmer is not verified.");

    ownerVerificator.addVerifiedProgrammer(bob);

    // TODO should fail because account-2 shouldnt be able to call addVerifiedProgrammer....
    // bob is not the owner of the smart contract, so he cannot add verified programmer
    Assert.equal(ownerVerificator.isProgrammerVerified(bob), true, "Programmer is verified.");
  }

  /// #sender: account-0
  /// #value: 100
  function checkAddingSmartContractVerificator() public {
    compareModifier(msg.sender, verificatorOwner);
    Verificator verificator = new Verificator();

    address smartContractVerificator = TestsAccounts.getAccount(2);
    verificator.addSmartContractVerificator(smartContractVerificator);

    address alice = TestsAccounts.getAccount(1);
    verificator.addVerifiedProgrammer(alice);
    Assert.ok(verificator.isProgrammerVerified(alice), "Programmer should be verified.");

    uint8 positivePoints = 2;
    // should only get called by smartContractVerificator
    (bool success, bytes memory data) = smartContractVerificator.call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", alice, positivePoints));
    Assert.equal(success, true, "Transaction should not revert if programmer is verified.");

    Assert.equal(verificator.isSmartContractVerificator(verificatorOwner), false, "Owner should not be a smart contract verificator.");
    // fails if the caller is no smart contract verificator
    (success, data) = verificatorOwner.call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", address(alice), uint8(positivePoints)));
    Assert.equal(success, false, "Transaction should revert if the caller is not a smart contract verificator.");

    // fails if the programmer address is not in the verified programmer list
    (success, data) = smartContractVerificator.call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", TestsAccounts.getAccount(0), positivePoints));
    Assert.equal(success, false, "Transaction should revert if the programmer is not verified.");
  }
}
