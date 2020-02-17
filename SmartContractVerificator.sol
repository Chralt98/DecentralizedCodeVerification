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

    // maximal five testers are possible
    uint8 public constant MAXIMUM_TESTERS = 5;
    // only verified programmer ethereum address list which registered for the verification of the smart contract
    // programmers verification is only valid if it is pushed with test code and another verified programmer evaluate the test code
    address[MAXIMUM_TESTERS] public testers;
    
    // first is verified programmer and second is if the smart contract is accepted
    // 60% of the verified programmers should accept the code to get verified
    mapping(address => bool) acceptanceMapping;
    
    // first address is address of tester, second is address of smart contract test
    mapping(address => address) testerSmartContractTestMapping;
    address[MAXIMUM_TESTERS] tests;
    
    // first is address of smart contract test
    // second is reviewer and third is rating of reviewer
    mapping(address => mapping(address => uint8)) testRatingMapping;
    
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
    
    modifier onlyTesters () {
        // check if msg.sender is a tester
        require(testers[msg.sender].exists, "Your address is not in the tester address list.");
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
    
    function checkSmartContractVerification() internal {
        require((locked == false), "The smart contract is already locked and the verification state is now certain.");
        // TODO every tester should accept the smart contract that it gets verified
        isVerified = true;
        locked = true;
    }
    
    // the tester has written a test for the to verified smart contract
    // after this the tester needs also to check another test of another tester, if not, he will not be rewarded
    function sendSmartContractTest(address _smartContractTest, bool _isAccepted) public onlyVerifiedProgrammer {
        // check if the tests and ratings are sufficing the smart contract verification 
        require((locked == false), "The smart contract is already locked and the verification state is now certain.");
        require(isContract(_smartContractTest), "Specified address is not a smart contract! Address should be a smart contract address.");
        require(!testers[msg.sender].exists, "You already sent a test for this smart contract.");
        require(testers.size <= MAXIMUM_TESTERS, "Maximum limit of testers is reached.");
        
        testers.add(msg.sender);
        acceptanceMapping[msg.sender] = _isAccepted;
        
        // tester could always override the test with a fresh one, but only until the smart contract test is not rated by another verified programmer
        testerSmartContractTestMapping[msg.sender] = _smartContractTest;
        tests.add(_smartContractTest);
    }
    
    function evaluateTestOfSmartContract(address _smartContractTestToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(tests[_smartContractTestToEvaluate].exists, "Specified address of test for the smart contract does not exist.");
        require((_smartContractTestToEvaluate == testerSmartContractTestMapping[msg.sender]), "You can not rate your own test.");
        require(!testRatingMapping[_smartContractTestToEvaluate][msg.sender].exists, "You already rated this test.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not 0 or 1 or 2, but has to be.");
        
        testRatingMapping[_smartContractTestToEvaluate][msg.sender] = _rating;
    }
    
    function getTests() public onlyVerifiedProgrammer returns (address[] memory) {
        return tests;
    }
    
    // verified programmer could suggest an amount the owner should pay
    function sendBestWeiOffer(uint256 _weiAmount) public onlyVerifiedProgrammer {
        bestWeiOffers[msg.sender] = _weiAmount;
    }
    
    // smart contract owner could see the price suggestions
    // only accessible because others should not see which price a verified programmer would pay 
    function getBestWeiOffers() public onlyOwner returns (mapping(address => uint256) memory){
        return bestWeiOffers;
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

