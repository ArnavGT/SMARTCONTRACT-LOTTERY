//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol"; // See solidity course to see how to use random numbers through solidity.

contract Lottery {
    address payable[] public players;
    uint256 USD_entryfee;
    uint256 ticketCost;
    AggregatorV3Interface internal eth_usdPriceFeed;
    address[] tickets;
    address Owner;

    // This is the different states of the Lottery contract that we are establishing and can be used
    enum LOTTERY_STATE {
        OPEN,
        CLOSED
    }

    LOTTERY_STATE public lottery_state;

    constructor(address _pf_address) public {
        USD_entryfee = 50 * (10**18);
        ticketCost = 2 * (10**18);
        eth_usdPriceFeed = AggregatorV3Interface(_pf_address);
        Owner = msg.sender;
        players.push(payable(Owner));
        tickets.push(Owner);
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN); //The lottery must be open.
        bool is_player = false;
        for (uint256 index = 0; index < players.length; index++) {
            if (msg.sender == players[index]) {
                is_player = true;
                break;
            }
        }

        require(
            is_player == false,
            "You are not a player yet! Enter the lottery first!"
        );

        // minimum 50$
        (uint256 condition, ) = getEntranceFee();
        require(msg.value >= condition);
        players.push(payable(msg.sender));
        tickets.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256, uint256) {
        (, int256 Price, , , ) = eth_usdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(Price) * 10**10;
        // Now we have 18 decimals since eth-usd priceFeed gives the feed in 8 decimals

        uint256 costToEnter = (USD_entryfee * 10**18) / adjustedPrice;
        uint256 ticket_cost_buy = (ticketCost * 10**18) / adjustedPrice;

        return (costToEnter, ticket_cost_buy);
    }

    function ticket_cost(uint256 _num_tickets) public view returns (uint256) {
        (, uint256 ticketcost) = getEntranceFee();
        return (_num_tickets * ticketcost);
    }

    function getTickets(uint256 _num_tickets) public payable {
        require(lottery_state == LOTTERY_STATE.OPEN);
        bool is_player = false;
        for (uint256 index = 0; index < players.length; index++) {
            if (msg.sender == players[index]) {
                is_player = true;
                break;
            }
        }

        require(
            is_player == true,
            "You are not a player yet! Enter the lottery first!"
        );

        (, uint256 _ticket_cost) = getEntranceFee();
        uint256 condition = _num_tickets * _ticket_cost;
        require(
            msg.value >= condition,
            "You have to spend more ETH for this many tickets. Check the ticket cost function to see how much!"
        );

        // write code here to see what happens after require condition == true
        for (uint256 count = 0; count < _num_tickets; count++) {
            tickets.push(msg.sender);
        }
    }

    function getWinner() public view returns (address[] memory) {
        return tickets;
    }

    function split_funds(address _winner) public payable {
        require(msg.sender == Owner, "You aren't the Owner!");

        uint256 funds_owner = (20 * address(this).balance) / 100;
        uint256 funds_winner = address(this).balance - funds_owner;

        payable(msg.sender).transfer(funds_owner);
        payable(_winner).transfer(funds_winner);

        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function reOpen_Lottery() public {
        lottery_state = LOTTERY_STATE.OPEN;
    }

    // This is a pseudo Random number predictor which uses different global variables such as block.difficulty, msg.value etc..
    // We take these variables, hash them together to get a random hash and divide the hash by the length of players to get a reminder which is included in the list
    // So its pretty random.
    // function pseudoRandom() public {
    //   return
    //       uint256(
    //           keccak256(
    //               abi.encodePacked(
    //                   nonce,
    //                   msg.sender,
    //                  block.difficulty,
    //                  block.timestamp
    //              )
    //          )
    //      ) % players.length; }

    // To inherit not only contracts onto other contract but also the contrat's constructor onto contracts, we can use:
    // constructor() <contract name>(<contract constructor parameters>) <view type> {}
    // This lets ur contract's constructor inherit from other contract's constructor.
}
