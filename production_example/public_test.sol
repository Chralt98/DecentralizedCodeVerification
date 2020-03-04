pragma solidity >=0.4.25 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Public_test.sol file !
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
// Public_smart_contract.sol file should be on the same directory level as this file
import "./private_smart_contract.sol";

contract PublicTest is PrivateSmartContract {
  address owner_account;
  address account_1;
  address account_2;

  function beforeAll() public {
    owner_account = TestsAccounts.getAccount(0);
    account_1 = TestsAccounts.getAccount(1);
    account_2 = TestsAccounts.getAccount(2);
  }

  /// #sender: account-0
  function checkGetOwnerAccount() public {
    compareModifier(msg.sender, owner_account);
    Assert.equal(get(), "Hello World!", "The constructor string should set to Hello World!");
  }

  /// #sender: account-1
  function checkGetAccount1() public {
    compareModifier(msg.sender, account_1);
    Assert.equal(get(), "Hello World!", "The constructor string should set to Hello World!");
  }

  /// #sender: account-2
  function checkGetAccount2() public {
    compareModifier(msg.sender, account_2);
    Assert.equal(get(), "Hello World!", "The constructor string should set to Hello World!");
  }

  /// #sender: account-0
  function checkSetAllowed() public {
    compareModifier(msg.sender, owner_account);
    Assert.equal(get(), "Hello World!", "The constructor string should set to Hello World!");
    string memory newVal = "I love cookies!";
    set(newVal);
    Assert.equal(get(), newVal, "The new value should be I love cookies!");
  }

  /// #sender: account-1
  function checkSetNotAllowed() public {
    compareModifier(msg.sender, account_1);
    Assert.equal(get(), "I love cookies!", "The value should be I love cookies!");
    string memory newVal = "Pizza is better than cookies!";
    // TODO transaction has been reverted by the evm so account-1 is now allowed to set
    set(newVal);
    Assert.equal(get(), "I love cookies!", "The value still should be I love cookies!");
  }

  /// #sender: account-1
  /// #value: 14
  function checkPayAndSet() payable public {
    compareModifier(msg.sender, account_1);
    compareValue(msg.value, 14);
    string memory newVal = "Pizza is really better than cookies!";
    Assert.equal(payAndSet(newVal), true, "The bool should be true, because account 1 payed more than 1 ether.");
    Assert.equal(get(), newVal, "The value should be Pizza is really better than cookies!");
    Assert.equal(getHighestBid(), 14, "Highest bid should be 14.");
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  function compareValue(uint256 _value, uint256 _sameValue) internal {
    Assert.equal(_value, _sameValue, "Both values should be the same.");
  }
}
