// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

contract ConsoleTest is Test {
    function testLogSomething() public pure {
        console.log("Log something here", uint256(123));

        int256 x = -1;
        console.logInt(x);
    }
}
