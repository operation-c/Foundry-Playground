// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { WETH } from "../src/WETH.sol";


contract WETH_Open_Invariant_Testing is Test {
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    function invariant_total_Supply() public view {
        assertEq(weth.totalSupply(), 0);
    }
}
