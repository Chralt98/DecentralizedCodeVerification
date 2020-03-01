pragma solidity ^0.6.2;

contract Verificator {
    address owner;

    mapping(address => bool) smartContractVerificatorExistanceMapping;
    mapping(address => uint) verifiedProgrammerPointsMapping;
    mapping(address => bool) goodProgrammerMapping;
    // at the beginning each new verified programmer gets 10 start points
    uint constant INITIAL_START_POINTS = 10;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "Your address is not the owner address!");
        _;
    }

    modifier onlySmartContractVerificator() {
        // TODO this address should be check that it is a smart contract verificator of this enterprise!
        require(smartContractVerificatorExistanceMapping[msg.sender], "Only callable by a smart contract verificator.");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    // test if one address is in the verified programmer list
    function isProgrammerVerified(address _addr) public view returns(bool) {
        if (verifiedProgrammerPointsMapping[_addr] > 0) return true;
        return false;
    }

    function getVerifiedProgrammerPoints(address _addr) public view returns(uint) {
        return verifiedProgrammerPointsMapping[_addr];
    }

    function isProgrammerAllowedToTest(address _addr) public view returns(bool) {
        return goodProgrammerMapping[_addr];
    }

    // should get called by the smart contract verificator!
    function addProgrammerPoints(address _programmer, uint8 _positivePoints) public onlySmartContractVerificator {
        require(verifiedProgrammerPointsMapping[_programmer] > 0, "Specified address is not in the list of verified programmers.");
        verifiedProgrammerPointsMapping[_programmer] += _positivePoints;
        goodProgrammerMapping[_programmer] = true;
    }

    // should get called by the smart contract verificator!
    function removeProgrammerPoints(address _programmer, uint8 _negativePoints) public onlySmartContractVerificator {
        require(verifiedProgrammerPointsMapping[_programmer] > 0, "Specified address is not in the list of verified programmers.");
        uint verifiedProgrammerPoints = verifiedProgrammerPointsMapping[_programmer];
        if (_negativePoints > verifiedProgrammerPoints) {
            verifiedProgrammerPointsMapping[_programmer] = 0;
        } else {
            // remove points
            verifiedProgrammerPointsMapping[_programmer] -= _negativePoints;
        }
        goodProgrammerMapping[_programmer] = false;
    }

    function addVerifiedProgrammer(address _programmer) public onlyOwner {
        require(verifiedProgrammerPointsMapping[_programmer] == 0, "Programmer address is already in the verified programmer address list.");
        verifiedProgrammerPointsMapping[_programmer] = INITIAL_START_POINTS;
        goodProgrammerMapping[_programmer] = true;
    }

    function addSmartContractVerificator(address _smartContractVerificator) public onlyOwner {
        require(!smartContractVerificatorExistanceMapping[_smartContractVerificator], "Smart contract verificator already exists.");
        smartContractVerificatorExistanceMapping[_smartContractVerificator] = true;
    }

    function deleteSmartContractVerificator(address _smartContractVerificator) public onlyOwner {
        require(smartContractVerificatorExistanceMapping[_smartContractVerificator], "Smart contract verificator does not exist.");
        smartContractVerificatorExistanceMapping[_smartContractVerificator] = false;
    }
}
