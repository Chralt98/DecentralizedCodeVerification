pragma solidity >=0.4.25 <0.7.0;

import "./SafeMath.sol";
import "./Verificator.sol";

// smart verified programmers check smart contract code for semantic weaknesses, errors and bugs and they will test it (write a test smart contract for that)
// let the registered programmers with the 50% best ratings get the reward stored in smart contract
// each registered programmer can call if the smart contract is accepted
// owner can not change the smart contract, there will be tests only written for this version and semantic comments
// the reward will be distributed always for the tests and comments and semantic reviews
contract SmartContractVerificator {
    // final verification states
    // active at beginning for the verification process and locked if not verified by the testers
    enum VerificationState {ACTIVE, LOCKED, VERIFIED}

    // event triggers and subscribers to the event can see it
    // stores the state of verification in the blockchain visible forever
    // indexed means event is not stored in log instead in topic
    event Verification (
        VerificationState indexed _state
    );

    VerificationState state;

    Verificator public programmerVerificator;

    // maximal five testers are possible
    uint8 public constant MAXIMUM_TESTERS = 5;

    // minimum amount of ratings to check if smart contract test has an average rating of 3
    uint8 public constant MINIMUM_RATINGS = 100;

    // only verified programmer ethereum address list which registered for the verification of the smart contract
    // programmers verification is only valid if it is pushed with test code and another verified programmer evaluate the test code
    address payable[] testers;
    mapping(address => bool) testersMapping;

    mapping(address => bool) testerBlacklist;

    // if tester joins then ++ if tester leaves -- for testerNumber
    uint testerNumber = 0;

    event TesterJoins();
    event TesterLeaves();
    event TesterRewarded(
        address _tester
    );

    // first is verified programmer and second is if the smart contract is accepted
    // 60% of the verified programmers should accept the code to get verified
    mapping(address => bool) acceptanceMapping;

    // first address is address of tester, second is address of smart contract test
    mapping(address => address) testerSmartContractTestMapping;
    // first is test and second is tester
    mapping(address => address) testSmartContractTesterMapping;

    address[] public tests;
    mapping(address => bool) testsMapping;
    mapping(address => bool) reviewerExistsMapping;

    address[] public swarmLevelTwoTests;
    address[] public swarmLevelTwoTesters;
    uint swarmLevelTwoTestIndex = 0;
    // first is address of smart contract test
    // second is reviewer and third is rating of reviewer
    mapping(address => mapping(address => uint8)) testReviewerRatingMapping;
    mapping(address => mapping(address => bool)) testReviewerHasRatedMapping;

    address[] public reviewer;

    // uints are the amount of added ratings
    struct Rating {
        bool exists;
        uint zeroPoints;
        uint onePoints;
        uint twoPoints;
    }

    // first is address of smart contract, second is rating of smart contract
    mapping(address => Rating) testRatingMapping;

    address public smartContractOwner;
    // owner is the creator of the to verified smart contract
    address public smartContractToVerify;

    modifier onlyOwner()  {
        require(msg.sender == smartContractOwner, "You are not the owner.");
        _;
    }

    modifier onlyVerifiedProgrammer () {
        // check if msg.sender is a verified programmer
        require(programmerVerificator.isProgrammerVerified(msg.sender), "Your address is not in the verified programmer address list.");
        _;
    }

    modifier onlyOwnerAndVerifiedProgrammer () {
        require(programmerVerificator.isProgrammerVerified(msg.sender) || msg.sender == smartContractOwner, "You have to be a verified programmer or the owner.");
        _;
    }

    modifier onlyTester () {
        // check if msg.sender is a tester
        require(testersMapping[msg.sender], "Your address is not in the tester address list.");
        _;
    }

    constructor(address _smartContract, address _programmerVerificator) public payable {
        require(isContract(_smartContract), "Specified address is not a smart contract! Address should be a smart contract address.");
        require((msg.value % MAXIMUM_TESTERS == 0), "Wei value should be dividable by 5 (MAXIMUM_TESTERS).");
        smartContractOwner = msg.sender;
        smartContractToVerify = _smartContract;
        programmerVerificator = Verificator(_programmerVerificator);
        state = VerificationState.ACTIVE;
        emit Verification(VerificationState.ACTIVE);
    }

    // verified programmers can look up if they could test the smart contract
    function isTesterSpace() public view returns (bool) {
        return testerNumber < MAXIMUM_TESTERS;
    }

    function increaseRewardStake() public payable {
        require((state == VerificationState.ACTIVE), "The smart contract is already locked or verified.");
        require((msg.value % MAXIMUM_TESTERS == 0), "Wei value should be dividable by 5 (MAXIMUM_TESTERS).");
    }

    function getRewardAmount() public view returns (uint) {
        return address(this).balance;
    }

    function getSmartContractToVerify() public view returns (address) {
        return smartContractToVerify;
    }

    function isSmartContractVerified() public view returns (bool) {
        return VerificationState.VERIFIED == state;
    }

    function getVerificationState() public view returns (string memory) {
        if (state == VerificationState.LOCKED) {
            return "LOCKED";
        } else if (state == VerificationState.VERIFIED) {
            return "VERIFIED";
        } else {
            return "ACTIVE";
        }
    }

    function getNumberOfEvaluations(address _smartContractTest) public view returns (uint) {
        uint zeros = testRatingMapping[_smartContractTest].zeroPoints;
        uint ones = testRatingMapping[_smartContractTest].onePoints;
        uint twos = testRatingMapping[_smartContractTest].twoPoints;
        return zeros + ones + twos;
    }

    function getTests() public view onlyVerifiedProgrammer returns (address[] memory) {
        return tests;
    }

    function getSwarmLevelTwoTests() public view onlyOwnerAndVerifiedProgrammer returns (address[] memory) {
        return swarmLevelTwoTests;
    }

    function getSwarmLevelTwoTesters() public view returns (address[] memory) {
        return swarmLevelTwoTesters;
    }

    // the tester has written a test for the to verified smart contract
    // after this the tester needs also to check another test of another tester, if not, he will not be rewarded
    function sendSmartContractTest(address _smartContractTest, bool _isAccepted) public onlyVerifiedProgrammer {
        require(msg.sender != smartContractOwner, "As owner you are not allowed to send a test for your smart contract.");
        // check if the tests and ratings are sufficing the smart contract verification
        require((state == VerificationState.ACTIVE), "The smart contract is either locked or verified.");
        require(isContract(_smartContractTest), "Specified address is not a smart contract! Address should be a smart contract address.");
        require(programmerVerificator.isProgrammerAllowedToTest(msg.sender), "Your address is not allowed to test, because your last evaluation was not in the swarm.");
        require(!testersMapping[msg.sender], "You already sent a test for this smart contract.");
        require(!testsMapping[_smartContractTest], "This smart contract address already exists.");
        require(testerNumber < MAXIMUM_TESTERS, "Maximum limit of testers is reached.");

        testers.push(msg.sender);
        testersMapping[msg.sender] = true;
        acceptanceMapping[msg.sender] = _isAccepted;
        testerSmartContractTestMapping[msg.sender] = _smartContractTest;
        testSmartContractTesterMapping[_smartContractTest] = msg.sender;
        tests.push(_smartContractTest);
        testsMapping[_smartContractTest] = true;

        emit TesterJoins();
        testerNumber++;
    }

    function evaluateTestOfSmartContract(address _smartContractTestToEvaluate, uint8 _rating) public onlyVerifiedProgrammer {
        require(msg.sender != smartContractOwner, "As owner you are not allowed to evaluate a test for your smart contract.");
        require(testsMapping[_smartContractTestToEvaluate], "Specified address of test for the smart contract does not exist.");
        require(!testersMapping[msg.sender], "You can not rate a test if you are a tester.");
        require(!testReviewerHasRatedMapping[_smartContractTestToEvaluate][msg.sender], "You already rated this test.");
        require(0 <= _rating && _rating <= 2, "Specified rating is not 0 or 1 or 2, but has to be.");

        testReviewerHasRatedMapping[_smartContractTestToEvaluate][msg.sender] = true;
        testReviewerRatingMapping[_smartContractTestToEvaluate][msg.sender] = _rating;

        if (!reviewerExistsMapping[msg.sender]) reviewer.push(msg.sender);
        reviewerExistsMapping[msg.sender] = true;

        if (!testRatingMapping[_smartContractTestToEvaluate].exists) testRatingMapping[_smartContractTestToEvaluate] = Rating(true, 0, 0, 0);
        if (_rating == 0) testRatingMapping[_smartContractTestToEvaluate].zeroPoints++;
        if (_rating == 1) testRatingMapping[_smartContractTestToEvaluate].onePoints++;
        if (_rating == 2) testRatingMapping[_smartContractTestToEvaluate].twoPoints++;

        checkSwarmIntelligence(_smartContractTestToEvaluate);
    }

    // starts with one reviewer parameters
    function checkSwarmIntelligence(address _smartContractTest) internal {
        require((state == VerificationState.ACTIVE), "The smart contract is either locked or verified.");

        uint zeros = testRatingMapping[_smartContractTest].zeroPoints;
        uint ones = testRatingMapping[_smartContractTest].onePoints;
        uint twos = testRatingMapping[_smartContractTest].twoPoints;

        uint ratingAmount = zeros + ones + twos;
        // first look if the smart contract test got 100 ratings
        // minimum limit for whole rating amount
        if (ratingAmount < MINIMUM_RATINGS) return;

        // let the verified programmers with the swarm intelligence get a good ranking to get selected for the next test of smart contract
        uint8 swarm;
        if (zeros > ones && zeros > twos) {
            swarm = 0;
        } else if (ones > zeros && ones > twos) {
            swarm = 1;
        } else if (twos > zeros && twos > ones) {
            swarm = 2;
        } else {
            // there is no majority, wait for the next reviewer
            return;
        }
        // evaluate the programmer reviewer which got the rating as swarm intelligence
        for (uint i = 0; i < reviewer.length; i++) {
            if (testReviewerRatingMapping[_smartContractTest][reviewer[i]] == swarm) {
                programmerVerificator.addProgrammerPoints(reviewer[i], 1);
            }
        }
        // tester is too bad
        if (swarm == 0 || swarm == 1) {
            // punish bad testers
            if (swarm == 0) programmerVerificator.removeProgrammerPoints(testSmartContractTesterMapping[_smartContractTest], 2);
            if (swarm == 1) programmerVerificator.removeProgrammerPoints(testSmartContractTesterMapping[_smartContractTest], 1);
            // remove tester and let another verified programmer get a chance to do a better test
            testerBlacklist[testSmartContractTesterMapping[_smartContractTest]] = true;
            // event for other verified programmers could test
            emit TesterLeaves();
            testerNumber--;
            return;
        }
        // swarm is 3 so the tester has written a good test
        swarmLevelTwoTesters.push(testSmartContractTesterMapping[_smartContractTest]);
        swarmLevelTwoTests.push(_smartContractTest);
        swarmLevelTwoTestIndex++;
        // if the last swarm level 2 contract is called this function (the maximum smart contract test with rating of 2) then checkSmartContractVerification
        if (swarmLevelTwoTestIndex == MAXIMUM_TESTERS) {
            rewardTesters();
            checkSmartContractVerification();
        }
    }

    function checkSmartContractVerification() internal {
        // now every tester got a rating of 3 and tester list is max
        // acceptanceMapping is for the whole smart contract verification
        // use only the acceptance mapping of the five swarmLevelTwo testers!
        for (uint i = 0; i < testers.length; i++) {
            // every tester should accept the smart contract to let it be verified
            if (!testerBlacklist[testers[i]] && acceptanceMapping[testers[i]] == false) {
                // one tester did not accept the smart contract to be verified
                state = VerificationState.LOCKED;
                emit Verification(VerificationState.LOCKED);
                return;
            }
        }
        // if no tester denied the smart contract, then it is verified
        state = VerificationState.VERIFIED;
        emit Verification(VerificationState.VERIFIED);
    }

    function rewardTesters() internal {
        uint amount = address(this).balance / MAXIMUM_TESTERS;
        for (uint i = 0; i < testers.length; i++) {
            if (!testerBlacklist[testers[i]]) {
                (bool success,) = testers[i].call.value(amount)("");
                if (success) emit TesterRewarded(testers[i]);
            }
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(_addr)}
        return size > 0;
    }
}
