pragma solidity >=0.4.25 <0.7.0;

contract PrivateSmartContract is PublicSmartContract {
  address payable owner;
  string public storedData;
  mapping (address => bool) payedMapping;

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not the owner!");
    _;
  }

  constructor() public {
    owner = msg.sender;
    storedData = "Hello World!";
  }

  function get() public view returns (string memory retVal) {
    return storedData;
  }

  function set(string memory newVal) public onlyOwner {
    storedData = newVal;
  }

  function pay(string memory newVal) public payable returns (bool) {
    if (msg.value >= 1 ether) {
      storedData = newVal;
      payedMapping[msg.sender] = true;
      owner.transfer(msg.value);
    } else {
      payedMapping[msg.sender] = false;
      (msg.sender).transfer(msg.value);
    }
    return payedMapping[msg.sender];
  }
}
