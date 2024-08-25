// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

contract Counter {
    uint256 public number;
    uint256 public count;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    // Function to increment count by 1
    function inc() public {
        console.log("HERE", count);
        count += 1;
    }

    // Function to decrement count by 1
    function dec() public {
        // This function will fail if count = 0
        count -= 1;
    }
}
