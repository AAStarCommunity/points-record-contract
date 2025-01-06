// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/points-record.sol";

contract DeployPointsRecord is Script {
    function run() external {
        // 获取私钥（现在应该包含 0x 前缀）
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 部署合约
        CommunityPointsRecord pointsRecord = new CommunityPointsRecord();

        // 结束广播
        vm.stopBroadcast();

        // 输出部署信息
        console.log("CommunityPointsRecord deployed to:", address(pointsRecord));
    }
} 