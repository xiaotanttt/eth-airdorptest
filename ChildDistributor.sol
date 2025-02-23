// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMainPool {
    function notifyDistributionComplete() external;
}

interface IChildContract {
    function distributeFunds() external;
}

contract ChildDistributor is IChildContract {
    // 使用动态数组，方便灵活配置空投地址数量
    address[] public wallets;
    address public mainContract;  // 主合约地址，后续由工厂设置

    event DistributionStarted();
    event DistributionCompleted();

    constructor(address[] memory _wallets) {
        wallets = _wallets;
    }

    // 仅允许在未设置时调用一次
    function setMainContract(address _mainContract) external {
        require(mainContract == address(0), "Main contract already set");
        require(_mainContract != address(0), "Invalid main contract");
        mainContract = _mainContract;
    }

    // 仅允许主合约调用
    function distributeFunds() external override {
        require(msg.sender == mainContract, "Unauthorized caller");
        emit DistributionStarted();

        // 此处示例：将当前合约余额均分给所有钱包
        uint256 walletCount = wallets.length;
        require(walletCount > 0, "No wallets available");
        uint256 amountPerWallet = address(this).balance / walletCount;

        for (uint256 i = 0; i < walletCount; i++) {
            (bool success, ) = wallets[i].call{value: amountPerWallet}("");
            require(success, "Transfer to wallet failed");
        }

        emit DistributionCompleted();
        // 分发完成后通知主合约
        IMainPool(mainContract).notifyDistributionComplete();
    }
}
