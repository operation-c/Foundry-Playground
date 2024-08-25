// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Event} from "../src/Event.sol";

// goal: test if events get emitted correctly
/**
 * 1. check if a single event is emited for "transfer"
 * 2. check if multiple events are emited for each transfer that is made in the loop
 */
contract EventTestingCheck is Test {
    Event public ev;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        ev = new Event();
    }

    function testEvtGetsEmited() public {
        vm.expectEmit(true, true, false, true);

        emit Transfer(address(this), address(123), 456);

        ev.transfer(address(this), address(123), 456);
    }

    function testManyEmitsTransfer() public {
        address[] memory to = new address[](2);
        to[0] = address(1);
        to[1] = address(2);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 123;
        amounts[1] = 456;

        for (uint256 i; i < to.length; i++) {
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amounts[i]);
            ev.transfer(address(this), to[i], amounts[i]);
        }
    }
}

// we will test to see if an event was emited or not

/**
 * how to check for single or multiple emits
 * 1. tell fondry which data to check
 * 2. Emit the expected event
 * 3. call the function that should emit the event
 */
contract EventTeste is Test {
    Event public e;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        e = new Event();
    }

    function testEmitTransferEvente() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), address(123), 456);
        e.transfer(address(this), address(123), 456);
    }

    function testEmitManyTransferEvents() public {
        address[] memory to = new address[](2);
        to[0] = address(111);
        to[1] = address(222);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = uint256(333);
        amounts[1] = uint256(444);

        for (uint256 i; i < to.length; i++) {
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amounts[i]);
        }
        e.transferMany(address(this), to, amounts);
    }
}

contract ErrorTest is Test {
    Event public e;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        e = new Event();
    }

    function testEmitTransferEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), address(123), 456);
        e.transfer(address(this), address(123), 456);
    }

    function testEmitManyTransferEvent() public {
        address[] memory to = new address[](2);
        to[0] = address(123);
        to[1] = address(456);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 789;
        amounts[1] = 999;

        for (uint256 i; i < to.length; i++) {
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amounts[i]);
        }
        e.transferMany(address(this), to, amounts);
    }
}
