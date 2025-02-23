contract ChildDistributor {
    address[15] public wallets;
    address public factory;

    constructor(address[15] memory _wallets) {
        factory = msg.sender;
        wallets = _wallets;
    }

    function distributeFunds() external {
        require(msg.sender == factory, "Unauthorized");
        uint256 groupCount = 5; // 15/3=5组
        uint256 amountPerGroup = address(this).balance / groupCount;

        for(uint i=0; i<groupCount; i++){
            uint256 start = i*3;
            uint256 end = start+3;
            _sendToGroup(start, end, amountPerGroup);
        }
    }

    function _sendToGroup(uint256 start, uint256 end, uint256 total) internal {
        uint256 perWallet = total / 3;
        for(uint i=start; i<end; i++){
            (bool success, ) = wallets[i].call{value: perWallet}("");
            require(success, "Transfer failed");
        }
    }
}
