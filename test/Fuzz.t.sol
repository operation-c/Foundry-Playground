// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MostSignificantBitFunction} from "../src/Bit.sol";

contract FuzzTesting is Test {
    MostSignificantBitFunction public b;

    function setUp() public {
        b = new MostSignificantBitFunction();
    }

    function mostSigBit(uint256 x) private pure returns (uint256) {
        uint256 i = 0;
        while((x >>= 1) > 0) {
            i++;
        }
        return i;
    }

    function testSignificantBitManual() public view {
        assertEq(b.mostSignificantBit(0), 0);
        assertEq(b.mostSignificantBit(1), 0);
        assertEq(b.mostSignificantBit(2), 1);
        assertEq(b.mostSignificantBit(4), 2);
        assertEq(b.mostSignificantBit(8), 3);
        assertEq(b.mostSignificantBit(type(uint256).max), 255);
    }

    function testBitFuzz(uint256 x) public view {

        vm.assume(x > 0);
        assertGt(x, 0);

        x = bound(x, 1, 10);
        assertGe(x, 1);
        assertLe(x, 10);


        uint256 i = b.mostSignificantBit(x);
        assertEq(i, mostSigBit(x));
    }
}
























































contract FuzzTest is Test {
    MostSignificantBitFunction public bit;

    function setUp() public {
        bit = new MostSignificantBitFunction();
    }

    function mostSignificantBit(uint256 x) private pure returns (uint256) {
        uint256 i = 0;
        while ((x >>= 1) > 0) {
            i++;
        }
        return i;
    }

    function testMostSignificantBitManual() public view {
        assertEq(bit.mostSignificantBit(0), 0);
        assertEq(bit.mostSignificantBit(1), 0);
        assertEq(bit.mostSignificantBit(2), 1);
        assertEq(bit.mostSignificantBit(4), 2);
        assertEq(bit.mostSignificantBit(type(uint256).max), 255);
    }

    function testMOstSignificantBitFuzz(uint256 x) public view {
        // vm.assume(x > 0);
        // assertGt(x, 0);

        x = bound(x, 1, 10);
        assertGe(x, 1);
        assertLe(x, 10);

        uint256 i = bit.mostSignificantBit(x);
        assertEq(i, mostSignificantBit(x));
    }
}
