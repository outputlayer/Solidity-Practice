// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface TokenContract {
    function faucet(uint x) external;
    function send(SendParam calldata _sendParam, MessagingFee calldata _fee, address _refundAddress) external payable;
    function quoteSend( SendParam calldata _sendParam, bool _payInLzToken) external view  returns (MessagingFee memory msgFee);

}

struct SendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

struct MessagingFee {
    uint nativeFee; // gas amount in native gas token
    uint lzTokenFee; // gas amount in ZRO token
}


contract Shower {
    TokenContract private tokenContract;
    address public tokenContractAddress = 0xFB5f1C1f58544e0620BA58239c2ae80378B054eA;
    address payable  owner;
    mapping (uint => uint32) network;



    constructor() {
        tokenContract = TokenContract(tokenContractAddress);
        owner = payable(msg.sender);
        network[0] = 40231; // arb 
        network[1] = 40245; // base 
    }

    receive() external payable {}



    function getFee(uint where, address addy ) private view returns (uint256) {
        bytes32 wallet = bytes32(uint256(uint160(addy)));
        SendParam memory sendParam = SendParam({
            dstEid: network[where],
            to: wallet,
            amountLD: 1000000000000000000,
            minAmountLD: 1000000000000000000,
            extraOptions: hex"00030100110100000000000000000000000000030d40",
            composeMsg: hex"",
            oftCmd: hex""
        });

        MessagingFee memory msgFee = tokenContract.quoteSend(sendParam, false);
        return msgFee.nativeFee;
    }



    function piss(uint n, address addy ) public payable  {
    require(msg.value > 0, "Ether value must be greater than 0");
    bytes32 wallet = bytes32(uint256(uint160(addy)));
    tokenContract.faucet(n);

    for (uint256 i = 0; i < n; i++) {
        uint index = i % 2; // 0 for even i, 1 for odd i
        uint256 fees = getFee(index, addy); 
    
        SendParam memory sendParam = SendParam({
            dstEid: network[index],
            to: wallet,
            amountLD: 1000000000000000000,
            minAmountLD: 1000000000000000000,
            extraOptions: hex"00030100110100000000000000000000000000030d40",
            composeMsg: hex"",
            oftCmd: hex""
        });

        MessagingFee memory fee = MessagingFee({
            nativeFee: fees,
            lzTokenFee: 0
        });

        tokenContract.send{value: fees}(sendParam, fee, addy);
        
    
    }
    owner.transfer(address(this).balance);
    
}


function getTotalFee(uint n, address addy ) public view returns (uint256) {
        bytes32 wallet = bytes32(uint256(uint160(addy)));
        uint totalfee = 0;
        for (uint256 i = 0; i < n; i++) {
        uint index = i % 2; // 0 for even i, 1 for odd i
        SendParam memory sendParam = SendParam({
            dstEid: network[index],
            to: wallet,
            amountLD: 1000000000000000000,
            minAmountLD: 1000000000000000000,
            extraOptions: hex"00030100110100000000000000000000000000030d40",
            composeMsg: hex"",
            oftCmd: hex""
        });

        MessagingFee memory msgFee = tokenContract.quoteSend(sendParam, false);
        totalfee += msgFee.nativeFee;
        }
        return totalfee;
    }






}
