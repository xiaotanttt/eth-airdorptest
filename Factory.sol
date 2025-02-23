contract Factory {
    MainPool public mainPool;

    function deployFullSystem(address[5][15] memory allWallets) external {
        // 部署5个子合约
        address[] memory children = new address[](5);
        for(uint i=0; i<5; i++){
            children[i] = address(new ChildDistributor(allWallets[i]));
        }
        
        // 部署主池
        mainPool = new MainPool(children);
    }
}
