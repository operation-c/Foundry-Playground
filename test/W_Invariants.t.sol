// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { Wallet } from "../src/Wallet.sol";

import { CommonBase } from "forge-std/Base.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

contract Wallet_Handler_Relayer is CommonBase, StdCheats, StdUtils, Test {
    Wallet public wallet;
    uint256 public totalSentToWallet;
    uint256 public totalWithdrawn;
    address public owner; 

    constructor(Wallet _wallet) {
        wallet = _wallet;
        owner = wallet.owner();
    }

    // test receive
    // Function to send ETH to the wallet contract
    function walletReceive(uint256 amount) public {  
        deal(address(this), 10 * 1e18 / 1e18);

        if (address(this).balance > 0 ) {
            
            // Bound the amount to the available balance in this contract
            amount = bound(amount, 1, address(this).balance);

            // Track the total ETH sent to the wallet contract
            totalSentToWallet += amount;

            // Sending ETH to the Wallet contract
            (bool ok, ) = address(wallet).call{value: amount}("");

            if (!ok) { 
                totalSentToWallet -= amount; revert("tx failed!"); 
            }
        } else {
            console.log("No balance to send");
        }
    }

    // function to send eth 
    function walletDeposit(uint256 amount) public {
        deal(address(this), 10 * 1e18 / 1e18);

        vm.assume(amount > 0);
        
        amount = bound(amount, 1, address(this).balance);

        totalSentToWallet += amount;

        wallet.deposit{value: amount}();
    }

    // test withdraw | with the designated value of the balance be > 0
    function walletWithdraw(uint256 amount) public {
        address _owner = wallet.owner();
        
        vm.assume(wallet.balanceOf(_owner) > 0);

        // withdraw amount logic 
        amount = bound(amount, 0, wallet.balanceOf(_owner));

        totalSentToWallet -= amount;
        totalWithdrawn += amount;

        // check to see if the withdrawer is the owner before attempting to withdraw 
        vm.prank(_owner);
        wallet.withdraw(amount);
    }

    // test setOwner 
    function walletSetOwner(address _newOwner) public {
        vm.prank(wallet.owner());
        wallet.setOwner(_newOwner);
        owner = _newOwner;
    }

}

contract Wallet_Iv_Tester is Test {
    Wallet public wallet;
    Wallet_Handler_Relayer public walletRelayer;

    function setUp() public {
        wallet = new Wallet();
        walletRelayer = new Wallet_Handler_Relayer(wallet);

        deal(address(walletRelayer), 10 * 1e18 / 1e18);
        targetContract(address(walletRelayer));
    }

    // // Ensure the Wallet contract's balance matches the total ETH sent to it
    function invariant_LL_Call() public view {
        console.log("Wallet balance:", address(wallet).balance/ 1e18);
        console.log("Wallet Relayer balance:", address(walletRelayer).balance / 1e18);

        assertEq(address(wallet).balance, walletRelayer.totalSentToWallet());
    }

    function invariant_wallet_deposit() public view {
        assertEq(address(wallet).balance, walletRelayer.totalSentToWallet());
    }

    function invariant_wallet_withdraw() public view {
        // total eth sent to wallet address should = the total eth withdrawn
        // totalDeposited == totalWithdrawn + ethStillInContract 
        assertEq(walletRelayer.totalSentToWallet(), walletRelayer.totalWithdrawn() + address(wallet).balance);
    }

    function invariant_wallet_setOwner() public view {
        assertEq(wallet.owner(), walletRelayer.owner());
    }
}