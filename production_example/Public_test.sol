pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Public_test.sol file !
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
// Public_smart_contract.sol file should be on the same directory level as this file
import "./Public_smart_contract.sol";

contract PublicTest is PublicSmartContract {
  address account_0;
  address account_1;
  address account_2;

  function beforeAll() {
    account_0 = TestsAccounts.getAccount(0);
    account_1 = TestsAccounts.getAccount(1);
    account_2 = TestsAccounts.getAccount(2);
  }

  /// #sender: account-1
  function checkGet() public {
    // TODO test get()
    compareModifier(msg.sender, account_1);
  }

  /// #sender: account-0
  function checkSet() public {
    // TODO test set()
    compareModifier(msg.sender, account_0);
  }

  /// #sender: account-2
  /// #value: 14
  function checkPay() public {
    // TODO test pay()
    compareModifier(msg.sender, account_2);
    
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }
}
