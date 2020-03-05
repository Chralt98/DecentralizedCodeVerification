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
  function beforeEach() public {}
  function afterEach() public {}
  function afterAll() public {}

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

  /// #sender: account-2
  /// #value: 3
  function checkPayAndSetFirstBid() payable public {
    compareModifier(msg.sender, account_2);
    compareValue(msg.value, 3);
    uint balanceBefore = account_2.balance;
    string memory newVal = "Cat food is the best.";
    Assert.ok(payAndSet(newVal), "The bool should be true, because account 2 payed more than 1 ether.");
    Assert.equal(get(), newVal, "Cat food is the best.");
    Assert.equal(getHighestBid(), 3, "Highest bid should be 3.");
    // but account-2 should get it's ether back
    Assert.lesserThan(account_2.balance, balanceBefore, "Account 2 should have lost funds.");
  }

  /// #sender: account-1
  /// #value: 2
  function checkPayAndSetLowBid() payable public {
    compareModifier(msg.sender, account_1);
    compareValue(msg.value, 2);
    uint balanceBefore = account_1.balance;
    string memory newVal = "Cat food is not the best!";
    Assert.equal(payAndSet(newVal), false, "The bool should be false, because 3 is the highest bid.");
    Assert.notEqual(get(), "Cat food is not the best!", "Value should be unchanged.");
    Assert.equal(getHighestBid(), 3, "Highest bid should be 3.");
    // but account-2 should get it's ether back
    Assert.equal(account_1.balance, balanceBefore, "Account 1 should not have lost funds.");
  }

  /// #sender: account-1
  /// #value: 14
  function checkPayAndSetHighestBid() payable public {
    compareModifier(msg.sender, account_1);
    compareValue(msg.value, 14);
    string memory newVal = "Pizza is really better than cookies!";
    uint balanceBefore = account_1.balance;
    uint highestBidBefore = getHighestBid();
    Assert.ok(payAndSet(newVal), "The bool is true, because account 1 has the greatest bid.");
    Assert.equal(get(), newVal, "The value should be Pizza is really better than cookies!");
    Assert.greaterThan(getHighestBid(), highestBidBefore, "Highest bid should have been increased.");
    Assert.equal(getHighestBid(), 14, "Highest bid should be 14.");
    Assert.lesserThan(account_1.balance, balanceBefore, "Account 1 should have lost funds.");
  }

  function compareModifier(address _sender, address _legitimately) internal {
    Assert.equal(_sender, _legitimately, "Not allowed to call this function.");
  }

  function compareValue(uint256 _value, uint256 _sameValue) internal {
    Assert.equal(_value, _sameValue, "Both values should be the same.");
  }
}
