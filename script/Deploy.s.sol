// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/NFTTicket.sol";
import "../src/DutchAuction.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        NFTTicket nftTicket = new NFTTicket();
        DutchAuction dutchAuction = new DutchAuction(address(nftTicket));

        vm.stopBroadcast();
    }
}
