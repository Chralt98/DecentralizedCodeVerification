pragma solidity >=0.4.25 <0.7.0;

/*
private smart contract owner has to descripe the smart contract
*/
interface PublicSmartContract {
    /*
    private smart contract owner has to descripe the function get()
    */
    function get() public external view returns (string);
    /*
    private smart contract owner has to descripe the function set()
    */
    function set(string) public external onlyOwner;
    /*
    private smart contract owner has to descripe the function pay()
    */
    function pay(string) public external payable returns (bool);
}
