// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChildContract {
    function distributeFunds() external;
}

contract MainPool {
    address public owner;
    IChildContract[5] public childContracts;
    uint256 constant CHILD_COUNT = 5;

    constructor(address[] memory childAddresses) {
        require(childAddresses.length == CHILD_COUNT, "Invalid child count");
        owner = msg.sender;
        for(uint i=0; i<CHILD_COUNT; i++){
            childContracts[i] = IChildContract(childAddresses[i]);
        }
    }

    receive() external payable {}

    function distributeToChildren() external {
        require(msg.sender == owner, "Unauthorized");
        uint256 balancePerChild = address(this).balance / CHILD_COUNT;
        
        for(uint i=0; i<CHILD_COUNT; i++){
            (bool sent, ) = address(childContracts[i]).call{value: balancePerChild}("");
            require(sent, "Transfer failed");
            childContracts[i].distributeFunds();
        }
    }
}
