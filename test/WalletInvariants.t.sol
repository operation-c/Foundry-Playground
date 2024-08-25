// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Wallet} from "../src/Wallet.sol";

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract WalletInvariants is Test {
    Wallet public wallet;
    WalletInvariants_Handler public walletHandler;

    // uint256 private constant WALLET_BALANCE = 2e18;
    // uint256 private constant TOLERANCE = 1e10;

    function setUp() public {  
        wallet = new Wallet();
        walletHandler = new WalletInvariants_Handler(wallet);

        deal(address(walletHandler), 10 * 1e18);

        targetContract(address(walletHandler));
        
    }

    // (runs: 256, calls: 128000, reverts: 85225)
    // with handler -> (runs: 256, calls: 128000, reverts: 64041)
    function invariant_balance_amount() public view {   

        assertEq(address(wallet).balance, walletHandler.walletBalance());
        console.log("wallet amount:", address(wallet).balance);

        // we are building a range 2eth with a tolerane of 1e10 for gas consumption 
        // assertGe(amount, WALLET_BALANCE - TOLERANCE, ">= 2eth"); 
        // assertLe(amount, WALLET_BALANCE, "<= 2eth");
    }

    // function invariant_setting_owner() public view {
    //     assertEq(wallet.owner(), walletHandler.newOwner());
    // }


}

contract WalletInvariants_Handler is CommonBase, StdCheats, StdUtils, Test {
    Wallet public wallet;
    address public newOwner;

    constructor(Wallet _wallet) {
        wallet = _wallet;
        newOwner = wallet.owner();
    }

    receive() external payable {}

    uint256 public walletBalance;

    function sendToReceive(uint256 amount) public {

        // assuring the amount will be greater than 0
        // vm.assume(amount > 0);
        // assertGt(amount, 0);

        if (address(this).balance > 0) { 
          // creating a bound for amount 
           amount = bound(amount, 1, address(this).balance);

           walletBalance  += amount;
        
            // assuring the amount will be greater than 0
            // assertGe(amount, 1);
            // assertLe(amount, address(this).balance);
                    // send eth using low level call
            (bool ok, ) = address(wallet).call{value: amount}("");
            if (!ok) { revert("tx failed!"); }
        
        } else {
            console.log("Skipping: Contract has no balance to send.");
        }

    } 

    function deposit(uint256 amount) public {
        // Ensure the wallet has a balance before proceeding
        if (address(wallet).balance > 0) {
            amount = bound(amount, 1, address(wallet).balance);  // Adjust bounds
            walletBalance -= amount;

            wallet.withdraw(amount);
        } else {
            console.log("Skipping: Wallet has no balance to withdraw.");
        }

        // making sure amount is greater than 0
        // vm.assume(amount > 0);
        // assertGt(amount, 0);

        // amount = bound(amount, 1, address(this).balance);

        // // assertGe(amount, 1);
        // // assertLe(amount, address(this).balance);

        // walletBalance  += amount;

        // wallet.deposit{value: amount}();
    }

    function withdraw(uint256 amount) public {

        if (address(wallet).balance > 0) {
            amount = bound(amount, 0, address(wallet).balance);
            walletBalance  -= amount;

            wallet.withdraw(amount);
        } else {
            console.log("Skipping: Wallet has no balance to withdraw.");
        }
        
    }

    function setOwner(address _newOwner) public {

        
        // [PASS] invariant_setting_owner() (runs: 256, calls: 128000, reverts: 64121)
        // require(_newOwner != address(0), "msg.sender is not the owner or it ='s address(0)!"); 
        
        // require(msg.sender == wallet.owner(), "msg.sender is not the owner!"); 
        
        // [PASS] invariant_setting_owner() (runs: 256, calls: 128000, reverts: 63916)

        // Ensure the new owner is not the zero address
        require(_newOwner != address(0), "New owner cannot be the zero address");

        // Ensure the caller is the current owner
        require(msg.sender == wallet.owner(), "msg.sender is not the owner!");

        // Update the owner if the new owner is different
        if (_newOwner != wallet.owner()) {
            wallet.setOwner(_newOwner);
            newOwner = _newOwner;
        }



        // if (_newOwner == address(0)) { revert("msg.sender == address(0)"); }
        
        // else  if (_newOwner == wallet.owner()) { console.log("no issues:"); return; }
        
        // else if (msg.sender == wallet.owner()) {
        //     wallet.setOwner(_newOwner); 
        //     newOwner = _newOwner;
        // } else {
        //         revert("msg.sender is not the owner");
        // } 
    }
}

