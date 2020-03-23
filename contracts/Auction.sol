pragma solidity ^0.5.0;

contract Auction {
    address payable public beneficiary;
    // Current state of the auction. You can create more variables if needed
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    bool auctionEnded;

    // Constructor
    constructor() public {
        beneficiary = msg.sender;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {

        require(
            !auctionEnded,
            "Auction already ended."
        );

        // TODO If the bid is not higher than highestBid, send the
        // money back. Use "require"
         require(
            msg.value > highestBid,
            "There already is a higher bid."
        );
        // TODO update state

        // TODO store the previously highest bid in pendingReturns. That bidder
        // will need to trigger withdraw() to get the money back.
        // For example, A bids 5 ETH. Then, B bids 6 ETH and becomes the highest bidder. 
        // Store A and 5 ETH in pendingReturns. 
        // A will need to trigger withdraw() later to get that 5 ETH back.
        if (highestBid != 0) {
                pendingReturns[highestBidder] += highestBid;
        }
        // Sending back the money by simply using
        // highestBidder.send(highestBid) is a security risk
        // because it could execute an untrusted contract.
        // It is always safer to let the recipients
        // withdraw their money themselves.
        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
        // TODO send back the amount in pendingReturns to the sender. Try to avoid the reentrancy attack. Return false if there is an error when sending
          pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
        // TODO make sure that only the beneficiary can trigger this function. Use "require"
         require(msg.sender==beneficiary, "Only Benificiary is allowed to call method");
        require(!auctionEnded, "auctionEnd has already been called.");

        // TODO send money to the beneficiary account. Make sure that it can't call this auctionEnd() multiple times to drain money
        auctionEnded = true;
        beneficiary.transfer(highestBid);
    }
}