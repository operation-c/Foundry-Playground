// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/IERC20Permit.sol";

contract ForkTest is Test {
    IERC20Permit public dai;

    function setUp() public {
        dai = IERC20Permit(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testDeposit() public {
        address alice = address(123);

        uint256 balBefore = dai.balanceOf(alice);
        console.log("balance before:", balBefore / 1e18);

        uint256 totalBefore = dai.totalSupply();
        console.log("total supply before:", totalBefore / 1e18);

        deal(address(dai), alice, 1e6 * 1e18, true);

        uint256 balAfter = dai.balanceOf(alice);
        console.log("balance before:", balAfter / 1e18);

        uint256 totalAfter = dai.totalSupply();
        console.log("total supply after:", totalAfter / 1e18);
    }
}
