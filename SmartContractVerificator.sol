pragma solidity ^0.6.2;

// TODO: list of every verified smart contract should be saved in blockchain

// owner is the creator of the to verified smart contract
contract SmartContractVerificator {
    bool internal isVerified = false;
    
    address constant public programmerVerificator = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    // only verified programmer ethereum address list
    address[] public registeredProgrammers;
    
    // wallet which holds the reward for the verificators 
    address payable public wallet;
    
    address public smartContractOwner;
    address public smartContractToVerify;
    
    modifier onlyOwner() {
        require(msg.sender == smartContractOwner);
        _;
    }
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(programmerVerificator.isVerified(msg.sender), "Your address is not in the verified programmer address list.");
        _;
    }
    
    modifier onlyRegisteredProgrammer () {
        // check if msg.sender is a registered programmer
        require(registeredProgrammers[msg.sender].exists, "Your address is not in the registered programmer address list.");
        _;
    }
    
    constructor(address _smartContract) public payable {
        require(isContract(_smartContract), "Specified address is not a smart contract! Address should be a smart contract address.");
        wallet.transfer(msg.value);
        smartContractOwner = msg.sender;
        smartContractToVerify = _smartContract;
    }
    
    function isSmartContractVerified() public returns (bool) {
        return isVerified;
    }
    
    function registerForVerification() public onlyVerifiedProgrammer {
        registeredProgrammers.add(msg.sender);
    }
    
    function getRewardWalletAddress() public returns(address) {
        return wallet;
    }
    
    function isContract(address _addr) internal returns (bool) {
        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}

contract ProgrammerVerificator {
    address owner;
    
    address[] public verifiedProgrammers;
    // address of ratings is one programmer
    // uint8[] size is the amount of ratings
    // uint8 is one rating
    // sum of uint8s divided by uint8[] size is the percentage of good ratings  
    mapping(address => uint8[]) public ratings;
    
    struct Riddle {
        string question;
        string[] possibleAnswers;
        uint8 correctAnswerIndex;
    }
    
    // let the examinee decide between 3 options of answers
    // should only be 100 riddles
    mapping(uint8 => Riddle) riddles;
    uint8 riddleIndex = 0;
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(verifiedProgrammers[msg.sender].exists, "Your address is not in the verified programmer address list.");
        _;
    }
    
    modifier onlyOwner () {
        // check if msg.sender is a verified programmer
        require(msg.sender == owner, "Your address is not the owner address!");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function isVerified(address _addr) public returns(bool) {
        if (verifiedProgrammers[_addr].exists) return true;
        return false;
    }
    
    // TODO: question: could multiple address use this function with no mutex problems?
    // would say yes because i am not working on global variables only with local ones
    function letMeBeAVerifiedProgrammer() public {
        require(!verifiedProgrammers[msg.sender].exists, "Your address is already in the verified programmer address list!");
        require(riddles.size() >= 100, "Not enough riddles have been added by the owner. Wait until owner added at least 100 riddles. Current riddle amount is " + riddles.size());
        // test the programmer skill with the riddles
        // first 100 added riddles
        uint8 _score = 0;
        // TODO: ask the sender 100 questions with for loop (interact with him)
        bool _passed = isTestPassed(_score);
        // TODO: if passed is false the programmer address should get blacklisted for an amount of time
        require(_passed == true, "Test failed. Your address has not been added to the verified programmer address list.");
        verifiedProgrammers.add(msg.sender);
    }
    
    function isTestPassed(uint8 _score) internal returns(bool) {
        require(_score >= 0, "Score has to be greater than or equals 0!");
        require(_score <= 100, "Score has to be smaller than or equals 100!");
        // if 90 % of the answers are true, then the test is passed
        if (_score >= 90) return true;
        return false;
    }
    
    // should only be called one time for each test of a programmer
    function evaluateProgrammer(address _programmerToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(verifiedProgrammers[_programmerToEvaluate].exists, "Specified address is not in the list of verified programmers.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not between 0 and 2.");
        // add rating to the verified programmer
        ratings[_programmerToEvaluate] = ratings[_programmerToEvaluate].add(_rating);
    }
    
    function getVerifiedProgrammers() public returns (address[] memory) {
        return verifiedProgrammers;
    }
    
    // owner could add shuffled version of riddles 
    function addRiddle(string memory _question, string[] memory _possibleAnswers, uint8 _correctAnswerIndex) public onlyOwner {
        require(riddleIndex < 100, "Only 100 riddles are needed for the test!");
        require(_possibleAnswers.size() == 3, "There have to be 3 possible answers!");
        require(0 <= _correctAnswerIndex && _correctAnswerIndex <= 2, "The correct answer index should be 0 or 1 or 2 (for 3 possible answers)!");
        riddles[riddleIndex] = Riddle(_question, _possibleAnswers, _correctAnswerIndex);
        riddleIndex++;
        // make an address which holds the question and answer then add the address to the list 
        // transfer this riddle to an IOTA address on the tangle and hold the transaction bundle id of iota here in eth
        // should not be made with ethereum, riddles should be in the tangle for 24/7 uptime (import the riddles into the ethereum blockchain)
        // but let the users of ethereum add a riddle, because they use a ETH address and are silly to use IOTA
    }
    
    // for refreshing the riddle list that every time another riddle list is created
    function deleteRiddles() public onlyOwner {
        riddles = [];
        riddleIndex = 0;
    }
}

