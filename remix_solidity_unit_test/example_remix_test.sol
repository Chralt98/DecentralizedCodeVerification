pragma solidity >=0.4.0 <0.7.0;

// IMPORTANT: only run this in the REMIX-IDE with the module SOLIDITY UNIT TESTING as Example_remix_test.sol file!!!
// IMPORTANT: this file is not accepted by the solidity compiler, but it can be executed by the SOLIDITY UNIT TESTING module
import "remix_tests.sol"; // this import is automatically injected by Remix.
// IMPORTANT: compiler does not know remix_accounts.sol, but solidity unit testing module accepts it
import "remix_accounts.sol";

contract HelloWorld {
  string public storedData;
  address owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not the owner!");
    _;
  }

  constructor() public {
    owner = msg.sender;
    storedData = "Hello world!";
  }

  function get() public view returns (string memory retVal) {
    return storedData;
  }

  function set(string memory newVal) public onlyOwner {
    storedData = newVal;
  }
}

contract ExampleRemixTest {
    HelloWorld foo;

    function beforeAll () public {
      foo = new HelloWorld();
    }
    function beforeEach() public {}
    function afterEach() public {}
    function afterAll() public {}

    function checkasserts () public {
      Assert.ok(true, "It is always true.");
      // OK => no error
      // assert.ok((1 == 0), "it\'s false"); => error: it's false
      bool a = true;
      bool b = false;
      bool c = true;
      Assert.equal(a, c, "error: a is not c");
      Assert.notEqual(a, b, "error: a is b");
      Assert.greaterThan(uint(2), uint(1), "1 is not greater than 2");
      Assert.lesserThan(int(1), int(2), "2 is not lesser than 1");
    }

    function initialValueShouldBeHelloWorld() public returns (bool) {
      return Assert.equal(foo.get(), "Hello world!", "initial value is not correct");
    }

    function valueShouldNotBeHelloWordl() public returns (bool) {
      return Assert.notEqual(foo.get(), "Hello wordl!", "value should not be hello wordl");
    }

    /// #sender: account-1
    function checkSenderIs1 () public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "wrong sender in checkSenderIs1");
    }

    /// #sender: account-0
    /// #value: 10
    function checkSenderIs0AndValueis10 () public payable {
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "wrong sender in checkSenderIs0AndValueis10");
        Assert.equal(msg.value, 10, "wrong value in checkSenderIs0AndValueis10");
    }

    /// #value: 100
    function checkValueIs100 () public payable {
        Assert.equal(msg.value, 100, "wrong value in checkValueIs100");
    }

    function checkSenderIsnt2 () public {
        Assert.notEqual(msg.sender, TestsAccounts.getAccount(2), "wrong sender in checkSenderIsnt2");
    }

    function checkValueIsnt10 () public payable {
        Assert.notEqual(msg.value, 10, "wrong value in checkValueIsnt10");
    }

    function checkSetAsOwner () public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "only the owner can call this test");
        string memory value = "I am the owner!";
        foo.set(value);
        Assert.equal(foo.get(), value, "value has not been set");
    }
}
