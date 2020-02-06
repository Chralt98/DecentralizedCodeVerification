pragma solidity ^0.6.2;

// owner is the creator of the to verified smart contract
contract SmartContractVerificator {
    address constant public programmerVerificator = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    // only verified programmer ethereum address list
    address[] public registeredProgrammers;
    address payable public wallet;
    address public smartContractOwner;
    address public smartContractToVerify;
    
    modifier onlyOwner() {
        require(msg.sender == smartContractOwner);
        _;
    }
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(programmerVerificator.isVerified(msg.sender), "Your address is not in the verified programmer list.");
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

contract ProgrammerVerificator {
    address constant public programmerRiddles = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    address[] public verifiedProgrammers;
    mapping(address => uint256[]) public ratings;
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(verifiedProgrammers[msg.sender].exists, "Your address is not in the verified programmer list.");
        _;
    }
    
    function isVerified(address _addr) public returns(bool) {
        if (verifiedProgrammers[_addr].exists) return true;
        return false;
    }
    
    function verifyProgrammer(address _programmer) public {
        require(!verifiedProgrammers[_programmer].exists, "Programmer is already verified!");
        testProgrammerSkill();
    }
    
    function testProgrammerSkill() internal {
        
    }
    
    function isTestPassed(uint256 _score) internal returns(bool) {
        require(_score >= 0, "Score has to be greater than or equals 0!");
        require(_score <= 100, "Score has to be smaller than or equals 100!");
        // if 90 % of the answers are true, then the test is passed
        if (_score >= 90) return true;
        return false;
    }
    
    function evaluateProgrammer(address _programmerToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(verifiedProgrammers[_programmerToEvaluate].exists, "Specified address is not in the list of verified programmers.");
        require(2 >= _rating && _rating <= 0, "Specified rating is not between 0 and 2.");
        ratings[_programmerToEvaluate] = ratings[_programmerToEvaluate].add(_rating);
    }
    
    function getVerifiedProgrammers() public returns (address[] memory) {
        return verifiedProgrammers;
    }
}

contract ProgrammerRiddles {
    address[] public riddles;
    // let the examinee decide between 3 options of answers
    mapping(string => string) public riddleMapping;
    
    function addRiddle(string memory _question, string memory _answer) public {
        // make an address which holds the question and answer then add the address to the list
        riddleMapping[_question] = _answer;
    }
}

