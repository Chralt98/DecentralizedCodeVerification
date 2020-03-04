pragma solidity >=0.4.25 <0.7.0;

import "./public_smart_contract.sol";

/*
this contract could be used for black box testing
*/
contract PrivateSmartContract is PublicSmartContract {
  address payable owner;
  string public storedData;

  event HighestBidIncreased(uint256 amount);
  uint256 highestBid;

  mapping (address => Payer) payerMapping;
  address[] payers;
  struct Payer {
    uint256 highestBid;
    uint256[] bids;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not the owner!");
    _;
  }

  constructor() public {
    owner = msg.sender;
    storedData = "Hello World!";
  }

  function get() public view override returns (string memory retVal) {
    return storedData;
  }

  function set(string memory newVal) public onlyOwner override {
    storedData = newVal;
  }

  function payAndSet(string memory newVal) public payable override returns (bool) {
    if (msg.value > highestBid) {
      storedData = newVal;
      highestBid = msg.value;
      emit HighestBidIncreased(highestBid);
      payerMapping[msg.sender].highestBid = msg.value;
      payerMapping[msg.sender].bids.push(msg.value);
      if (payerMapping[msg.sender].bids.length == 1) payers.push(msg.sender);
      owner.transfer(msg.value);
      return true;
    }
    (msg.sender).transfer(msg.value);
    return false;
  }

  function getHighestBid() public override returns (uint256) {
    return highestBid;
  }

  function getBids(address _addr) public override returns (uint256[] memory) {
    return payerMapping[_addr].bids;
  }

  function getPayers() public override returns (address[] memory) {
    return payers;
  }
}
