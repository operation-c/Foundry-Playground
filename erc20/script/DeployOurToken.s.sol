// SPDX-License-Identifier: MIT 

import { Script } from "forge-std/Script.sol";
import { OurToken } from "../src/OurToken.sol";

pragma solidity ^0.8.18;

contract DeployOurToken is Script {

    uint256 public constant INITIAL_SUPPLY = 2000 * 10 ** 18;


    address bob = makeAddr("bob");

    function run() external returns (OurToken) {
        vm.startBroadcast();

        OurToken ot = new OurToken(INITIAL_SUPPLY);
                
        vm.stopBroadcast();
    
        return ot;
    }
}