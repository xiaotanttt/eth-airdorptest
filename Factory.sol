// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MainPool.sol";
import "./ChildDistributor.sol";

contract Factory {
    MainPool public mainPool;
    ChildDistributor[] public childDistributors;

    // deployFullSystem 接受一个二维数组，每个内层数组为一个子合约的空投地址列表
    function deployFullSystem(address[][] memory childWallets) external {
        uint256 childCount = childWallets.length;
        require(childCount > 0, "No child wallet groups provided");

        // 部署所有子合约
        IChildContract[] memory children = new IChildContract[](childCount);
        for (uint256 i = 0; i < childCount; i++) {
            ChildDistributor child = new ChildDistributor(childWallets[i]);
            childDistributors.push(child);
            children[i] = IChildContract(address(child));
        }
        
        // 部署主合约并传入子合约地址
        mainPool = new MainPool(children);
        
        // 更新每个子合约的主合约地址
        for (uint256 i = 0; i < childDistributors.length; i++) {
            childDistributors[i].setMainContract(address(mainPool));
        }
    }
}
