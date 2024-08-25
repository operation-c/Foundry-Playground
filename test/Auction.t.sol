// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";

contract AuctionTeste is Test {
    Auction public auction;
    uint256 private startAt;

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    function testBidFailsBeforeStartTimee() public {
        vm.expectRevert(bytes("cannot bid"));
        auction.bid();
    }

    function testBidd() public {
        vm.warp(startAt + 1 days);
        auction.bid();
    }

    function testBidddFailsAfterEndTime() public {
        vm.expectRevert(bytes("cannot bid"));
        vm.warp(startAt + 2 days);
        auction.bid();
    }

    function testTimeStamps() public {
        uint256 t = block.timestamp;
        skip(100);
        assertEq(block.timestamp, t + 100, "checking time stamps");

        rewind(10);
        assertEq(block.timestamp, t + 100 - 10, "rewinding the timestamp");
    }

    function testBlockNumber() public {
        vm.roll(999);
        assertEq(block.number, 999, "checking block number");
    }
}

contract TimeTest is Test {
    Auction public auction;
    uint256 private startAt;

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    // we expect the bid to fail since time has not yet elapsed
    function testBidFailsBeforeStartTime() public {
        vm.expectRevert(bytes("cannot bid"));
        auction.bid();
    }

    function testBid() public {
        vm.warp(startAt + 1 days);
        auction.bid();
    }

    function testBidFailsAfterEndDate() public {
        vm.expectRevert(bytes("cannot bid"));
        vm.warp(startAt + 2 days);
        auction.bid();
    }

    function testTimeStamp() public {
        uint256 t = block.timestamp;

        skip(100);
        assertEq(block.timestamp, t + 100);

        // rewind
        rewind(10);
        assertEq(block.timestamp, t + 100 - 10);
    }

    function testBlockNumber() public {
        uint256 b = block.number;
        vm.roll(999);
        assertEq(block.number, 999);
    }
}
