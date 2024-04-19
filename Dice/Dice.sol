// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


import {VRFCoordinatorV2Interface} from "@chainlink/contracts@1.0.0/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts@1.0.0/src/v0.8/vrf/VRFConsumerBaseV2.sol";



contract VRFv2Consumer is VRFConsumerBaseV2 {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; 
        bool exists; 
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; 
    VRFCoordinatorV2Interface COORDINATOR; 

    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
   

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625){
        COORDINATOR = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625); 
         s_subscriptionId = subscriptionId;
    }

    function requestRandomWords() external returns (uint256 requestId)
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords( uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}




interface TokenContract {
    function lastRequestId() external view returns (uint256);
    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords);
    function requestRandomWords() external returns (uint256 requestId);
}


contract DiceGame {
    address public owner;
    TokenContract tokenContract;
    address public vrfConsumerAddress;
    

    struct BetInfo {
        uint256 roundID;
        uint256 value;
        uint256 hilo;
        uint256 randomnum;
        address from;
        string status;
        string paid;
    }

    mapping(address => mapping(uint256 => BetInfo)) public bets;
    mapping(address => uint256) public latestBetId;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    constructor() payable {
        owner = payable(msg.sender);
        vrfConsumerAddress = address(new VRFv2Consumer(11107));
        update(vrfConsumerAddress);
        
    }

    function update(address x) public onlyOwner{
        tokenContract = TokenContract(x);
    }

    function deposit() public payable onlyOwner {}

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function bet(uint256 hilo) public payable {
        require(msg.value > 0, "Your value should be more than 0!");
        require((address(this).balance)/3 > msg.value, "You reached maxbet");
        BetInfo storage userBet = bets[msg.sender][latestBetId[msg.sender]];
        if (keccak256(bytes(userBet.paid)) == keccak256(bytes("not paid"))) {
            _claim(msg.sender, latestBetId[msg.sender]);
        }
        require(hilo == 0 || hilo == 1, "You should use only 0 - to bet on low and 1 - to bet on high");
        bool fulfilled = false;
    uint256[] memory randomWords;
    
    try tokenContract.getRequestStatus(userBet.roundID) returns (bool _fulfilled, uint256[] memory _randomWords) {
        fulfilled = _fulfilled;
        randomWords = _randomWords;
    } catch {
        // If an error occurs, set fulfilled to true
        fulfilled = true;
    }


        if (!fulfilled) {
            latestBetId[msg.sender] += 1;
            bets[msg.sender][latestBetId[msg.sender]] = BetInfo({
                roundID: tokenContract.lastRequestId(),
                value: msg.value,
                hilo: hilo,
                from: msg.sender,
                randomnum: 999,
                status: "pending",
                paid: "not paid"
            });
        }

        if (fulfilled) {
            tokenContract.requestRandomWords();
            latestBetId[msg.sender] += 1;
            bets[msg.sender][latestBetId[msg.sender]] = BetInfo({
                roundID: tokenContract.lastRequestId(),
                value: msg.value,
                hilo: hilo,
                from: msg.sender,
                randomnum: 999,
                status: "pending",
                paid: "not paid"
            });
        }
    }

    function _claim(address player, uint256 betId) internal {
        BetInfo storage userBet = bets[player][betId];
        require(keccak256(bytes(userBet.paid)) == keccak256(bytes("not paid")), "You have nothing to claim!");
        (bool fulfilled, uint256[] memory randomWords) = tokenContract.getRequestStatus(userBet.roundID);
        require(fulfilled, "Request not fulfilled");
        uint256 lastNumber = randomWords[0] % 100;
        if ((userBet.hilo == 0 && lastNumber < 49) || (userBet.hilo == 1 && lastNumber > 51)) {
            require(address(this).balance > userBet.value * 2, "Casino can't pay at this time :(");
            payable(userBet.from).transfer(userBet.value * 2);
            userBet.status = "Won";
        } else {
            userBet.status = "Lost";
        }
        userBet.paid = "paid";
        userBet.randomnum = lastNumber;
    }

    function claim() public payable {
        _claim(msg.sender, latestBetId[msg.sender]);
    }
}

