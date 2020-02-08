pragma solidity ^0.6.2;

import "./SafeMath.sol";

// TODO: list of every verified smart contract should be saved in blockchain

// smart verified programmers check smart contract code for semantic weaknesses, errors and bugs and they will test it (write a test smart contract for that)
// let the registered programmers with the 50% best ratings get the reward stored in the wallet
// each registered programmer can call if the smart contract is accepted
// owner can not change the smart contract, there will be tests only written for this version and semantic comments
// the reward will be distributed always for the tests and comments and semantic reviews
// TODO: how the programm can ensures that not every evaluation is trash for a quick reward ?
contract SmartContractVerificator {
    // final variable to occupy the smart contract verification
    bool internal isVerified;
    
    // if locked is true, then the smart contract is finally verified or not and additional ratings and tests have no effect on the verification
    bool internal locked;
    
    address constant public programmerVerificator = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;

    // only verified programmer ethereum address list which registered for the verification of the smart contract
    // programmers verification is only valid if it is pushed with test code and another verified programmer evaluate the test code
    address[] public registeredProgrammers;
    
    // first is registered programmer and second is if the smart contract is accepted
    // 60% of the registered programmers (testers) should accept the code to get verified
    // TODO: at least 100 acceptances ? define the minimum
    mapping(uint => mapping(address => bool)) acceptanceMapping;
    uint internal voteCounter = 0;
    uint internal sumOfAcceptance = 0;
    
    // first address is address of a registered programmer, second is address of smart contract test
    mapping(address => address) testsForSmartContractMapping;
    
    // first is reviewer, second is rating
    mapping(address => uint8) reviewerRatingMapping;
    
    // first is address of smart contract test
    // reward only the 100 fastest testers with good rating
    mapping(address => reviewerRatingMapping) testReviewMapping;
    
    // wallet which holds the reward for the verificators 
    address payable public wallet;
    
    address public smartContractOwner;
    // owner is the creator of the to verified smart contract
    address public smartContractToVerify;
    
    // only one wei best offer for one verified programmer
    // for the owner, that he knows what the price should be
    mapping(address => uint256) internal bestWeiOffers;
    
    
    modifier onlyOwner() {
        require(msg.sender == smartContractOwner);
        _;
    }
    
    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(programmerVerificator.isProgrammerVerified(msg.sender), "Your address is not in the verified programmer address list.");
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
    
    function increaseRewardStake() public payable onlyOwner {
        wallet.transfer(msg.value);
    }
    
    function getSmartContractToVerify() public returns (address) {
        return smartContractToVerify;
    }
    
    function isSmartContractVerified() public returns (bool) {
        return isVerified;
    }
    
    function checkSmartContractVerification(bool _accepted) internal {
        require((locked == false), "The smart contract is locked and the verification state is now certain.");
         // rules when the smart contract is finally accepted by the registered and good rated programmers (testers)
        if (_accepted) sumOfAcceptance++;
        // TODO: let the owner decide how much validations he want to have but at least 100
        if (voteCounter <= 100) return;
        uint percentAcceptance = SafeMath.div((sumOfAcceptance * 100), voteCounter);
        
        // 60 % of registered programmers have to vote for acceptance that the smart contract will be verified
        if (percentAcceptance >= 60) {
            isVerified = true;
        } else {
            // 40 % ore more did not accept the smart contract 
            isVerified = false;
        }
        locked = true;
        rewardTesters();
    }
    
    function rewardTesters() {
        // TODO: let only reward the testers with at least a rating of 1
        // only reward testers who evaluated at least three other testers
    }
    
    // the registered programmer has written a test for the to verified smart contract
    // after this the tester needs also to check another test of another tester, if not, he will not be rewarded
    function sendSmartContractTestWithAcceptanceToBeVerified(address _smartContractTest, bool _isAccepted) public onlyRegisteredProgrammer {
        require(isContract(_smartContractTest), "Specified address is not a smart contract! Address should be a smart contract address.");
        require(!testReviewMapping[msg.sender].exists, "One test of your address is already rated by a verified programmer.");
        // tester could always override the test with a fresh one, but only until the smart contract test is not rated by another verified programmer
        testsForSmartContractMapping[msg.sender] = _smartContractTest;
        if (!acceptanceMapping.get(1)[msg.sender].exists) {
            // tester can only vote ones
            acceptanceMapping[voteCounter][msg.sender] = _isAccepted;
            voteCounter++;
        }
        
        // check if the tests and ratings are sufficing the smart contract verification 
        require((locked == false), "The smart contract is locked and the verification state is now certain.");
    }
    
    function getRandomTestOfSmartContract() public onlyVerifiedProgrammer returns (address) {
        // assert that test is not written by the caller of this function
        
        // assert that its not a test that is already evaluated by the msg.sender
        
        // get one random smart contract test, which is not evaluated
        // second if there is no test of smart contract which is not evaluated than take random smart contract which is only evaluated one time and so on...
    }
    
    function evaluateTestOfSmartContract(address _smartContractTestToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(testsForSmartContractMapping.get(1)[_smartContractTestToEvaluate].exists, "Specified address of test for the smart contract does not exist.");
        require((_smartContractTest == testsForSmartContractMapping[msg.sender]), "You can not rate your own test.");
        require(!testReviewMapping[_smartContractTestToEvaluate][msg.sender], "You already rated this test.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not 0 or 1 or 2, but has to be.");
        
        testReviewMapping[_smartContractTestToEvaluate][msg.sender] = _rating;
        
        // evaluate programmer in the programmer verificator
        address tester = testsForSmartContractMapping.get(0)[_smartContractTest];
        ProgrammerVerificator.evaluateProgrammer(tester, _rating);
        
        // for a valid tester the rating has to be 1 or 2
        if (_rating > 0) {
            address tester = testsForSmartContractMapping.get(1)[_smartContractTestToEvaluate];
            bool accepted = acceptanceMapping.get(1)[tester];
            checkSmartContractVerification(accepted);
        }
    }
    
    function registerForVerification() public onlyVerifiedProgrammer {
        require(!registeredProgrammers[msg.sender].exists, "Your address is already in the registered programmer address list.");
        registeredProgrammers.add(msg.sender);
    }
    
    // verified programmer could suggest an amount the owner should pay
    function sendBestWeiOffer(uint256 _weiAmount) public onlyVerifiedProgrammer {
        bestWeiOffers[msg.sender] = _weiAmount;
    }
    
    // smart contract owner could see the price suggestions
    // only accessible because others should not see which price a verified programmer would pay 
    function getBestWeiOffers() public onlyOwner returns (mapping(address => uint256)){
        return getBestWeiOffers;
    }
    
    // that others could see what the reward is
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
    
    function isProgrammerVerified(address _addr) public returns(bool) {
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
    
    // TODO: this is called in the Smart Contract Verificator => have to check if verified programmer could be the smart contract verificator itself or hand over the msg.sender a verified programmer
    // TODO: not sure if the calling Smart contract Verificator calls as onlyVerifiedProgrammer
    // should only be called one time for each test of a programmer
    function evaluateProgrammer(address _programmerToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(verifiedProgrammers[_programmerToEvaluate].exists, "Specified address is not in the list of verified programmers.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not 0 or 1 or 2, but has to be.");
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

