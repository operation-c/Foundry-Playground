// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/IERC20Permit.sol";

contract USDC is Test {
    IERC20Permit public usdc;
    address private constant HEFNER = address(123);

    function setUp() public {
        usdc = IERC20Permit(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

    function testWhaleMinting() public {
        uint256 balBefore = usdc.balanceOf(HEFNER);
        console.log("balance before:", balBefore / 1e18);

        uint256 totalSupplyBefore = usdc.totalSupply();
        console.log("total supply before:", totalSupplyBefore / 1e18);

        deal(address(usdc), HEFNER, 1e7 * 1e18, true);

        uint256 balAfter = usdc.balanceOf(HEFNER);
        console.log("balance after:", balAfter / 1e18);

        uint256 totalSupplyAfter = usdc.totalSupply();
        console.log("total supply after:", totalSupplyAfter / 1e18);
    }
}
