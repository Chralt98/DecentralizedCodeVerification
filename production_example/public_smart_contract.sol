pragma solidity >=0.4.25 <0.7.0;

/*
private smart contract owner has to descripe the smart contract
this interface is for the white tester
*/
interface PublicSmartContract {
    /*
    private smart contract owner has to descripe the function get()
    */
    function get() external view returns (string memory);
    /*
    private smart contract owner has to descripe the function set()
    */
    function set(string calldata) external;
    /*
    private smart contract owner has to descripe the function payAndSet()
    */
    function payAndSet(string calldata) external payable returns (bool);
    /*
    private smart contract owner has to descripe the function getHighestBid()
    */
    function getHighestBid() external returns (uint256);
    /*
    private smart contract owner has to descripe the function getBids()
    */
    function getBids(address) external returns (uint256[] memory);
    /*
    private smart contract owner has to descripe the function getPlayers()
    */
    function getPayers() external returns (address[] memory);
}
