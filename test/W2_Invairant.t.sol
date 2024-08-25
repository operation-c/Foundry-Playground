// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { Wallet } from "../src/Wallet.sol";

import { CommonBase } from "forge-std/Base.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";


contract W2_Handler is CommonBase, StdCheats, StdUtils, Test {
    Wallet public wallet;
    uint256 public totalEthSent;
    uint256 public totalEthWithdrawn;
    address public newOwner;

    constructor(Wallet _wallet) {
        wallet = _wallet;
        newOwner = wallet.owner();
    }

    // receive 
    function w2_receive(uint256 amount) public {
        deal(address(this), 10 * 1e18);

        if (address(this).balance > 0) {
            amount = bound(amount, 1, address(this).balance);

            totalEthSent += amount;

            (bool ok, ) = address(wallet).call{value: amount}("");
            if (!ok) { totalEthSent -= amount; revert("tx failed"); }
        } else { console.log("no balance to send"); }
    
    }

    // deposit 
    function w2_deposit(uint256 amount) public {
        deal(address(this), 10 * 1e18);

        if(address(this).balance > 0) {
            amount = bound(amount, 1, address(this).balance);

            totalEthSent += amount;
            wallet.deposit{value: amount}();
        } else { console.log("Nothing to send"); }
    }


    // withdraw 
    function w2_withdraw(uint256 amount) public {

        vm.assume(wallet.balanceOf(wallet.owner()) > 0);   

        // make sure the amount that we with draw is valid
        // make sure we can only with draw between 0 - whats stored in wallet contract | bound 
        amount = bound(amount, 0, wallet.balanceOf(wallet.owner()));

        // update the balance of totalsentETh;
        totalEthSent -= amount;
        // update the balance of totalEthWithdrawn
        totalEthWithdrawn += amount;

        // call withdraw of the owner
        vm.prank(wallet.owner());
        wallet.withdraw(amount); 

    }


    // setOwner 
    function w2_setOwner(address _newOwner) public {
        vm.prank(wallet.owner());
        newOwner = _newOwner;
        wallet.setOwner(_newOwner);
        
    }

    function failer() public pure {
        revert("failed");
    }
}

contract W2_Invariant_Test is Test {
    Wallet public wallet;
    W2_Handler public w2Handler;

    function setUp() public {
        wallet = new Wallet();
        w2Handler = new W2_Handler(wallet);

        deal(address(w2Handler), 10 * 1e18);
        targetContract(address(w2Handler));
         
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = W2_Handler.w2_deposit.selector;
        selectors[1] = W2_Handler.w2_receive.selector;
        selectors[2] = W2_Handler.w2_setOwner.selector;
        selectors[3] = W2_Handler.w2_withdraw.selector;

        targetSelector(
            FuzzSelector({
                addr: address(w2Handler), 
                selectors: selectors})
            );
    }

    // the amount that was deposited matches the total amount of eth sent
    function invariant_w2_receive() public view {
        assertEq(address(wallet).balance, w2Handler.totalEthSent());
    }

    // checking the amount that is deposited is the same amount inside the contract 
    // this time will be calling the deposit function 
    function invariant_w2_deposit() public view {
        assertEq(address(wallet).balance, w2Handler.totalEthSent());
    }

    // checking to see if the same amount of eth that was deposited into the wallet is able to be withdrawn 
    // total eth balance is sent -> wallet balanace gets updated -> withdrawn 
    // 10 (total sent), 2 (withdrawn) + 8 (current balance)
    // check total sent, amount that was withdrawn + current balance 
    function invariant_w2_withdraw() public view {
        assertEq(w2Handler.totalEthSent(), w2Handler.totalEthWithdrawn() + address(wallet).balance);
    }

    // testing to see if the wallet contract can correctly assign random address as the new owner 
    function invariant_w2_setOwner() public view {
        assertEq(wallet.owner(), w2Handler.newOwner());
    }
} 