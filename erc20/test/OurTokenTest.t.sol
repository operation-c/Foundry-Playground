// SPDX-License-Identifier: MIT 

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { OurToken } from "../src/OurToken.sol";
import { DeployOurToken } from "../script/DeployOurToken.s.sol";

pragma solidity ^0.8.18;

// testing the constructor 
contract OurTokenTester is Test {
    OurToken public ourToken;
    uint256 private constant INITIAL_SUPPLY = 1000000 * 10 ** 18; // Example initial supply

    function setUp() public {
        // Deploy the OurToken contract with the initial supply
        ourToken = new OurToken(INITIAL_SUPPLY);
    }

    function testTokenName() public {
        // Test that the token name is correctly set
        assertEq(ourToken.name(), "OurToken");
    }

    function testTokenSymbol() public {
        // Test that the token symbol is correctly set
        assertEq(ourToken.symbol(), "OT");
    }

    function testInitialSupply() public {
        // Test that the initial supply is correctly minted to the deployer's address
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);

        // Test that the deployer's balance is equal to the initial supply
        assertEq(ourToken.balanceOf(address(this)), INITIAL_SUPPLY);
    }
}


// testing erc20 transfer, approve and allowance 
contract OurTokenTest is Test {

    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 private constant BOBS_STARTING_BALANCE = 1000 * 10 ** 18;
    uint256 private constant CONTRACT_STARTING_BALANCE = 1000 * 10 ** 18;
    address private receiver = address(0x1);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        
        // Assuming the deployer address is the one deploying the contract and gets the initial supply
        vm.prank(msg.sender);
        ourToken.transfer(msg.sender, CONTRACT_STARTING_BALANCE);
        console.log("contract balance:", ourToken.balanceOf(msg.sender));


        vm.prank(msg.sender);
        ourToken.transfer(bob, BOBS_STARTING_BALANCE);
        // console.log("bobs balance:", ourToken.balanceOf(bob));
    }


    function testFailTransferExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.prank(msg.sender);
        ourToken.transfer(receiver, amount);
    }

    function testFailApproveExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.expectRevert();
        vm.prank(msg.sender);
        ourToken.approve(receiver, amount);
    }


    // testing transfer 
    function testTransfer() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(msg.sender);
           
        ourToken.transfer(receiver, amount);

        // the balance of the contract should now be 0, since we transfer the entire amount to the receiver contract 
        assertEq(ourToken.balanceOf(address(this)), 0);
    }

    // testing transferFrom 
    function testTransferFrom() public {
        uint256 amount = 10 * 10 ** 18;

        vm.prank(msg.sender);
        ourToken.approve(receiver, amount);
        
        uint256 allowance = ourToken.allowance(msg.sender, receiver);
        console.log("Allowance set:", allowance);

        vm.prank(receiver);
        ourToken.transferFrom(msg.sender, receiver, amount);

        // checking to see if the receivers balance got updated 
        assertEq(ourToken.balanceOf(receiver), amount, "first test");
        console.log("receviers balanaoce:", ourToken.balanceOf(receiver));

        // check to see if the balance of the msg.sender is now reduced by the amount that was transfered over to the receiver
        assertEq(ourToken.balanceOf(msg.sender), CONTRACT_STARTING_BALANCE - amount, "second test");
        console.log("contracts balance after the transfer to receiver:", ourToken.balanceOf(msg.sender));

        // check to see if the allowance of the receiver is now 0, since the entire allowance was spent and transfered to the receiver(itself)
        assertEq(ourToken.allowance(msg.sender, receiver), 0);
        console.log("allowance left for the receiver:", ourToken.allowance(msg.sender, receiver));
    }


    // during inception should expect bob to have a starting balance of 100 ether; 
    function testBobBalance() public view {
        assertEq(BOBS_STARTING_BALANCE, ourToken.balanceOf(bob));
        console.log("Bobs balance:", ourToken.balanceOf(bob)/ 1e18);
    }


    function testAllowance() public {
        uint256 initialAllowance = 1000;
        // alice approves bob to spend tokens on her behalf
        // bob is approving alice access to 1000 
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        console.log("alice's begining balance:", ourToken.balanceOf(alice));
        console.log("bob's begining balance:", ourToken.balanceOf(bob));

        uint256 transferAmount = 500;

        // alice calls transferFrom with the approver (bob) to send 500 tokens to herself 
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // alice should now have a balance of 500 and the transfer amount was 500
        assertEq(ourToken.balanceOf(alice), transferAmount);
        console.log("alice's balance after check:", ourToken.balanceOf(alice));

        // bob started with a balance of 1000 but should now have 99999999999999999500 
        assertEq(ourToken.balanceOf(bob), BOBS_STARTING_BALANCE - transferAmount);
        console.log("bob's balance after check:", BOBS_STARTING_BALANCE - transferAmount);
    }

    
}