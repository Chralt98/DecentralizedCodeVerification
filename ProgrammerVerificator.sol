pragma solidity ^0.6.2;

// TODO: problem some other attacker could use also this smart contract if the attacker finds out this smart contract address
contract ProgrammerVerificator {
    address owner;
    
    mapping(address => bool) verifiedProgrammers;
    
    mapping(address => uint8) programmerScoreMapping;
    // one address of ratings is one verified programmer
    mapping(address => uint) public ratings;
    // if 11 fails the user got not at least 90% for 100 questions
    uint8 constant MAXIMUM_FAILS = 11;
    mapping(address => uint8) pointMapping;
    mapping(address => uint8) failMapping;
    mapping(address => bool) isResolutionAllowedMapping;
    
    struct Riddle {
        string question;
        string[] possibleAnswers;
        uint8 correctAnswerIndex;
    }
    
    // let the examinee decide between 3 options of answers
    mapping(uint => Riddle) riddles;
    uint8 riddleIndex = 0;
    
    modifier onlyVerifiedProgrammer() {
        // check if msg.sender is a verified programmer
        require(verifiedProgrammers[msg.sender], "Your address is not in the verified programmer address list.");
        _;
    }
    
    modifier onlyOwner() {
        // check if msg.sender is a verified programmer
        require(msg.sender == owner, "Your address is not the owner address!");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function isProgrammerVerified(address _addr) public returns(bool) {
        if (verifiedProgrammers[msg.sender]) return true;
        return false;
    }
    
    // TODO: problem do not get the riddles easy out to the addresses which call this smart contract function to protect the difficulty
    function getRiddle(uint _riddleIndex) public returns(string memory, string[] memory) {
        require(!verifiedProgrammers[msg.sender], "Your address is already in the verified programmer address list!");
        require(riddleIndex >= 100, "Not enough riddles have been added by the owner. Wait until owner added at least 100 riddles.");
        require(isResolutionAllowedMapping[msg.sender], "You are not allowed to get a riddle until you solve the last riddle.");
        isResolutionAllowedMapping[msg.sender] = true;
        return (riddles[_riddleIndex].question, riddles[_riddleIndex].possibleAnswers);
    }
    
    // TODO: problem do not get the riddles easy out to the addresses which call this smart contract function to protect the difficulty
    function isRiddleSolved(uint _riddleIndex, uint8 _answerIndex) public returns(bool) {
        require(!verifiedProgrammers[msg.sender], "Your address is already in the verified programmer address list!");
        require(riddleIndex >= 100, "Not enough riddles have been added by the owner. Wait until owner added at least 100 riddles.");
        // TODO for now each failer gets blacklisted forever, do we want this or use a time blacklist ?
        require(failMapping[msg.sender] < MAXIMUM_FAILS, "Your address reached the maximum of fails for the riddles.");
        bool isCorrect = (riddles[_riddleIndex].correctAnswerIndex == _answerIndex);
        if (isCorrect) {
            pointMapping[msg.sender]++;
        } else {
            failMapping[msg.sender]++;
        }
        if (isTestPassed(pointMapping[msg.sender])) verifiedProgrammers[msg.sender] = true;
        isResolutionAllowedMapping[msg.sender] = false;
        return isCorrect;
    }
    
    function isTestPassed(uint8 _score) internal returns(bool) {
        require(_score >= 0, "Score has to be greater than or equals 0!");
        require(_score <= 100, "Score has to be smaller than or equals 100!");
        // if 90 % of the answers are true, then the test is passed
        if (_score >= 90) return true;
        return false;
    }
    
    // TODO: this is called in the Smart Contract Verificator => have to check if verified programmer could be the smart contract verificator itself or hand over the msg.sender a verified programmer
    // TODO: not sure if the calling Smart contract Verificator calls as onlyVerifiedProgrammer
    // should only be called one time for each test of a programmer
    function evaluateProgrammer(address _programmerToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(verifiedProgrammers[_programmerToEvaluate], "Specified address is not in the list of verified programmers.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not 0 or 1 or 2, but has to be.");
        // add rating to the verified programmer
        ratings[_programmerToEvaluate] += _rating;
    }
    
    function getVerifiedProgrammers() public returns (mapping(address => bool) memory) {
        return verifiedProgrammers;
    }
    
    // owner could add shuffled version of riddles 
    function addRiddle(string memory _question, string[] memory _possibleAnswers, uint8 _correctAnswerIndex) public onlyOwner {
        require(riddleIndex < 100, "Only 100 riddles are needed for the test!");
        require(_possibleAnswers.length == 3, "There have to be 3 possible answers!");
        require(0 <= _correctAnswerIndex && _correctAnswerIndex <= 2, "The correct answer index should be 0 or 1 or 2 (for 3 possible answers)!");
        riddles[riddleIndex] = Riddle(_question, _possibleAnswers, _correctAnswerIndex);
        riddleIndex++;
        // TODO following ?
        // make an address which holds the question and answer then add the address to the list 
        // transfer this riddle to an IOTA address on the tangle and hold the transaction bundle id of iota here in eth
        // should not be made with ethereum, riddles should be in the tangle for 24/7 uptime (import the riddles into the ethereum blockchain)
        // but let the users of ethereum add a riddle, because they use a ETH address and are silly to use IOTA
    }
    
    function getRiddlesWithAnswers() public onlyOwner returns(mapping(uint => Riddle) memory) {
        return riddles;
    }
    
    // for refreshing the riddle list that every time another riddle list is created
    function deleteRiddle(uint _riddleIndex) public onlyOwner {
        require(_riddleIndex >= 0, "Your riddle index should be greater than zero.");
        delete riddles[_riddleIndex];
    }
}

