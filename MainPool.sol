// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChildContract {
    function distributeFunds() external;
}

contract MainPool {
    address public owner;
    IChildContract[] public childContracts;

    // 调度相关状态变量
    uint256 public currentChildIndex;
    bool public inProgress;

    event ChildDistributionStarted(uint256 indexed childIndex, address child);
    event ChildDistributionCompleted(uint256 indexed childIndex, address child);

    constructor(IChildContract[] memory _childContracts) {
        require(_childContracts.length > 0, "No child contracts provided");
        owner = msg.sender;
        childContracts = _childContracts;
    }

    receive() external payable {}

    // 依次启动各个子合约的空投
    function startNextChildDistribution() external {
        require(msg.sender == owner, "Unauthorized");
        require(currentChildIndex < childContracts.length, "All distributions completed");
        require(!inProgress, "Distribution in progress");

        // 将剩余资金均分给剩下的子合约
        uint256 remainingChildren = childContracts.length - currentChildIndex;
        uint256 balancePerChild = address(this).balance / remainingChildren;

        inProgress = true;
        address childAddr = address(childContracts[currentChildIndex]);
        emit ChildDistributionStarted(currentChildIndex, childAddr);

        // 先转账给当前子合约，再调用其空投函数
        (bool sent, ) = childAddr.call{value: balancePerChild}("");
        require(sent, "Transfer to child failed");
        childContracts[currentChildIndex].distributeFunds();
    }

    // 供子合约空投结束后回调
    function notifyDistributionComplete() external {
        require(msg.sender == address(childContracts[currentChildIndex]), "Invalid callback caller");
        emit ChildDistributionCompleted(currentChildIndex, msg.sender);
        inProgress = false;
        currentChildIndex++;
    }
}
