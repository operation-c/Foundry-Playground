// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

// fuzz test: a single function is tested multiple times with different inputs
// invariants: sequence of functions are randomly called


contract IntoInvariant {
    bool public flag;

    function func_1() external { flag = false; }

    function func_2() external { flag = false; }

    function func_3() external { flag = true; }
    function func_4() external { flag = false; }
    function func_5() external {}

    function func_6() external {
        
    }
}

contract IntoInvariantTest is Test {
    IntoInvariant private target;

    function setUp() public {
        target = new IntoInvariant();
    }

    function invariant_flag_is_always_false() public view {
        assertEq(target.flag(), false);
    }
}
