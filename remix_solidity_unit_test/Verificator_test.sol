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
  address verifiedProgrammer;
  address smartContractVerificator;

  function beforeAll() public {
    verificator = new Verificator();
    verificatorOwner = TestsAccounts.getAccount(0);
    verifiedProgrammer = TestsAccounts.getAccount(1);
    smartContractVerificator = TestsAccounts.getAccount(2);
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  /// #sender: account-0
  /// #value: 100
  function checkAddingVerifiedProgrammer() public {
    compareModifier(msg.sender, verificatorOwner);
    verificator.addVerifiedProgrammer(verifiedProgrammer);
    uint expectedProgrammerPoints = 10;
    Assert.ok(verificator.isProgrammerVerified(verifiedProgrammer), "Programmer should be verified.");
    Assert.ok(verificator.isProgrammerAllowedToTest(verifiedProgrammer), "Programmer should be allowed to test after adding as verified programmer.");
    Assert.equal(verificator.getVerifiedProgrammerPoints(verifiedProgrammer), expectedProgrammerPoints, "Programmer should have 10 points initially after adding as verified programmer.");

    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encodeWithSignature("addVerifiedProgrammer(address)", verifiedProgrammer));
    Assert.equal(success, false, "Transaction should revert if address is already verified.");
  }

  /// #sender: account-1
  function checkAddingVerifiedProgrammerNotLegitimate() public{
    compareModifier(msg.sender, verifiedProgrammer);

    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encodeWithSignature("addVerifiedProgrammer(address)", verificatorOwner));
    Assert.equal(success, false, "Transaction should revert if address is not legitimate to add a verified programmer.");

    // TODO fix this issue
    Assert.equal(verificator.isProgrammerVerified(verificatorOwner), false, "Programmer is not verified.");

    verificator.addVerifiedProgrammer(verificatorOwner);

    // TODO should fail because account-2 shouldnt be able to call addVerifiedProgrammer....
    // bob is not the owner of the smart contract, so he cannot add verified programmer
    Assert.equal(verificator.isProgrammerVerified(verificatorOwner), true, "Programmer is verified.");
  }

  /// #sender: account-0
  /// #value: 100
  function checkAddingSmartContractVerificator() public {
    compareModifier(msg.sender, verificatorOwner);
    verificator.addSmartContractVerificator(smartContractVerificator);
    Assert.equal(verificator.isSmartContractVerificator(smartContractVerificator), true, "Smart contract verificator should have been added.");
  }

  /// #sender: account-2
  function checkAddingProgrammerPointsSucceed() public {
    compareModifier(msg.sender, smartContractVerificator);
    uint8 positivePoints = 2;
    // should only get called by smartContractVerificator (account-2) => should succeed, because alice is already verified above
    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", verifiedProgrammer, positivePoints));
    Assert.equal(success, true, "Transaction should not revert if programmer is verified and called by smart contract verificator.");
  }

  /// #sender: account-2
  function checkAddingProgrammerPointsNotVerified() public {
    compareModifier(msg.sender, smartContractVerificator);
    address notVerifiedProgrammer = verificatorOwner;
    uint8 positivePoints = 2;
    // fails if the programmer address is not in the verified programmer list
    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", notVerifiedProgrammer, positivePoints));
    Assert.equal(success, false, "Transaction should revert if the programmer is not verified.");
  }

  /// #sender: account-0
  function checkAddingProgrammerPointsNoneSmartContractVerificator() public {
    compareModifier(msg.sender, verificatorOwner);
    uint8 positivePoints = 2;
    Assert.equal(verificator.isSmartContractVerificator(verificatorOwner), false, "Owner should not be a smart contract verificator.");
    // should only get called by smartContractVerificator (account-2) => should revert
    (bool success, bytes memory data) = address(verificator).call.gas(40000).value(0)(abi.encodeWithSignature("addProgrammerPoints(address,uint8)", verifiedProgrammer, positivePoints));
    Assert.equal(success, false, "Transaction should revert if the caller is not a smart contract verificator.");
  }
}
