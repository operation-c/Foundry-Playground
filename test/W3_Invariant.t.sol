// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { Wallet } from "../src/Wallet.sol";
import { W2_Handler } from "./W2_Invairant.t.sol";

import { CommonBase } from "forge-std/Base.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

contract ActorManagers is CommonBase, StdCheats, StdUtils {
    W2_Handler[] public handlers;

    constructor(W2_Handler[] memory _handlers) {
        handlers = _handlers;
    }

    function _sendToFallBack(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].w2_receive(amount);
    }

    function _deposit(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].w2_deposit(amount);
    }

    function _withdraw(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].w2_withdraw(amount); 
    }
}

contract W2_Multi_Handler_Tester is Test {
    Wallet public wallet;
    ActorManagers public manager;
    W2_Handler[] public handlers;

    function setUp() public {
        wallet = new Wallet();
        for (uint256 i; i < 3; i++) {
            handlers.push(new W2_Handler(wallet));
            deal(address(handlers[i]), 10 * 1e18);
        }

        manager = new ActorManagers(handlers);
    
        targetContract(address(manager));
    }

    // total amount of eth locked in the wallet contract must be >= than the total deposited by the handler
    function invariant_ethereum_balance() public view {
        uint256 total = 0;
        for (uint256 i; i < handlers.length; i++){
            total += handlers[i].totalEthSent();
        }
        console.log("Eth total:", total/ 1e18);
        assertGe(address(wallet).balance, total);
    }
}