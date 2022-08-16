// SPDX-License-Identifier : MIT

pragma solidity ^0.8.7;

/*
What to achieve
1. User provides liquidity to thirs party
2. On delivery fund should be transffered to seller
3. Buyer can withdraw money in case of no delivery
*/

contract Escrow {
    enum EscrowState {
        Not_Initialized,
        Initiated,
        Awaiting_Delivery,
        Delivery_Successful,
        End
    }
    uint256 public amount;
    address public buyer;
    address public seller;
    EscrowState public currentState;
    bool public isBuyerIn;
    bool public isSellerIn;

    event FundAdded(address indexed funder, uint256 indexed amount);
    event Delivered(address indexed Seller, uint256 indexed amount);
    event EscrowAccepted(address indexed _yourAddress);
    event EscrowInitialized(
        address indexed _buyer,
        address indexed _seller,
        string msg
    );

    constructor(
        uint256 _amountToBuy,
        address _selller,
        address _buyer
    ) {
        amount = _amountToBuy;
        seller = _selller;
        buyer = _buyer;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can perform this operation");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can perform this operation");
        _;
    }

    modifier escrowNotInitialized() {
        require(
            currentState == EscrowState.Not_Initialized,
            "Escrow not initialized"
        );
        _;
    }

    function BuyerIn() public onlyBuyer {
        isBuyerIn = true;
        emit EscrowAccepted(buyer);
    }

    function SellerIn() public onlySeller {
        isSellerIn = true;
        emit EscrowAccepted(seller);
    }

    function InitializeEscrow() public escrowNotInitialized {
        if (isBuyerIn != true) {
            revert("Buyer is not in yet");
        }

        if (isSellerIn != true) {
            revert("Seller is not in yet");
        }

        if (isBuyerIn && isSellerIn) {
            currentState = EscrowState.Initiated;
        }
        emit EscrowInitialized(buyer, seller, "Buyer and Seller, Both are in");
    }

    function AddFund() public payable onlyBuyer {
        if (currentState != EscrowState.Initiated) {
            revert();
        }
        if (msg.value != amount) {
            revert();
        }
        currentState = EscrowState.Awaiting_Delivery;
        emit FundAdded(buyer, amount);
    }

    function Withdraw() public onlyBuyer {
        if (currentState != EscrowState.Awaiting_Delivery) {
            revert();
        }
        currentState = EscrowState.End;
        payable(buyer).transfer(address(this).balance);
    }

    function DeliverySuccessful() public onlyBuyer {
        if (currentState != EscrowState.Awaiting_Delivery) {
            revert();
        }
        currentState = EscrowState.Delivery_Successful;
        payable(seller).transfer(address(this).balance);
    }

    function getContractFund() public view returns (uint256) {
        return address(this).balance;
    }
}
