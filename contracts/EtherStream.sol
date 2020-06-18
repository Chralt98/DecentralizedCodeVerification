pragma solidity >=0.4.25 <0.7.0;


import "@openzeppelin/contracts/payment/PaymentSplitter.sol";
import "@openzeppelin/contracts/payment/PullPayment.sol";

// https://docs.openzeppelin.com/contracts/3.x/api/payment
contract EtherStream is PullPayment {

    PaymentSplitter paymentSplitter;
    uint256 weiPerSecond;

    constructor(address[] payees, uint256[] shares, uint256 weiPerSecond) PullPayment() public {
        paymentSplitter = new PaymentSplitter(payees, shares);
        this.weiPerSecond = weiPerSecond;
    }

    function startStream() public view {
        // TODO: call this every second
        this._asyncTransfer(address(paymentSplitter), weiPerSecond);
        this.withdrawPayments(address(paymentSplitter));
    }
}