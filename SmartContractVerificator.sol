pragma solidity ^0.6.2;

contract SmartContractVerificator {
    // only verified programmer ethereum address list
    address[] public registeredProgrammers;
    address payable public wallet;
    address smartContractOwner;
    address public smartContractToVerify;
    
    modifier onlyOwner() {
        require(msg.sender == smartContractOwner);
        _;
    }
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        address[] memory verifiedProgrammers = ProgrammingSkillVerificator(msg.sender).getVerifiedProgrammers();
        require(verifiedProgrammers[msg.sender].exists, "Your address is not in the verified programmer list.");
        _;
    }
    
    modifier onlyRegisteredProgrammer () {
        // check if msg.sender is a registered programmer
        require(registeredProgrammers[msg.sender].exists, "Your address is not in the registered programmer list.");
        _;
    }
    
    constructor(address _smartContract) public payable {
        require(isContract(_smartContract), "Specified address is not a smart contract!");
        wallet.transfer(msg.value);
        smartContractOwner = msg.sender;
        smartContractToVerify = _smartContract;
    }
    
    function registerForVerification() public onlyVerifiedProgrammer {
        registeredProgrammers.add(msg.sender);
    }
    
    function getWalletAddress() public returns(address) {
        return wallet;
    }
    
    function isContract(address _addr) internal returns (bool) {
        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}

contract ProgrammingSkillVerificator {
    address[] public verifiedProgrammers;
    
    function verifyProgrammer(address _programmer) public {
        testProgrammerSkill();
    }
    
    function testProgrammerSkill() internal {
        
    }
    
    function passedTest() internal returns(bool) {
        // if 100 % of the answers of the questions are true, then the test is passed
        return true;
    }
    
    function getVerifiedProgrammers() public returns (address[] memory) {
        return verifiedProgrammers;
    }
}

contract ProgrammerRiddles {
    address[] public riddles;
    mapping(string => string) public riddleMapping;
    
    function addRiddle(string memory _question, string memory _answer) public {
        // make an address which holds the question and answer then add the address to the list
        riddleMapping[_question] = _answer;
    }
}
