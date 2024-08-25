// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletTesterAuth is Test {
    Wallet public wallet;
    uint256 private constant WALLET_BALANCE = 2e18;
    uint256 private constant TOLERANCE = 354;
    

    event Deposit(address indexed account, uint256 amount);

    function setUp() public {
        // Deploy the wallet contract with 1 ETH
        wallet = new Wallet{value: WALLET_BALANCE}();

        // Set the wallet contract as the target for fuzzing
        targetContract(address(wallet));
    }

    // Invariant function to check the total supply
    function invariant_total_supply() public view {
        // Example invariant logic
        uint256 actualBalance = address(wallet).balance;
        console.log("wallet balance:", address(wallet).balance);

        assertGe(actualBalance, WALLET_BALANCE - TOLERANCE);
        assertLe(actualBalance, WALLET_BALANCE, "<= assertion!");
    }





    function _send(uint256 amount) private {
        (bool ok,) = address(wallet).call{value: amount}("");
        if (!ok) revert("tx failed");
    }


    function testEthBalance() public view {
        console.log("ETH balance:", address(this).balance / 1e18);
    }

    function testSendEth() public {
        uint256 bal = address(wallet).balance;
        deal(address(1), 100);
        assertEq(address(1).balance, 100);

        hoax(address(1), 123);
        _send(123);

        assertEq(address(wallet).balance, bal + 123);
    }

    // testing events
    function testOsit() public {
        console.log("test contract balance:", address(this).balance / 1e18);

        deal(address(wallet), 10 * 1e18);

        // checking balance of wallet
        console.log("old wallet balance:", address(wallet).balance / 1e18);

        // now checking if deposit event from the receive function will trigger
        vm.expectEmit(true, false, false, true);

        emit Deposit(address(this), 1e18);

        // calling receive function
        (bool ok,) = address(wallet).call{value: 1e18}("");
        if (!ok) revert("tx failed!");

        console.log("new wallet balance:", address(wallet).balance / 1e18);

        assertEq(address(wallet).balance, 11 * 1e18, "wallet balance should be 11");
        console.log("test contract after balance:", address(this).balance / 1e18);
    }

    // testing setting an owner w/ out permissions
    function testSettingWrongOwner() public {
        vm.expectRevert();
        vm.prank(address(1));
        wallet.setOwner(address(2));
    }

    // testing if we output the error msg when we call set the onwer with an address that does not have permission
    function testErrorMessageSetOwner() public {
        //
        vm.expectRevert(bytes("caller is not owner"));
        vm.prank(address(1));
        wallet.setOwner(address(1));
    }

    // testing if we can assign an owner if the correct permissions
    function testSetOwnerFor() public {
        console.log("OG owner:", wallet.owner());
        wallet.setOwner(address(1));
        console.log("New owner:", wallet.owner());
    }

    /**
     * TESTs
     * 1. assign new owner to the wallet contract
     *     a. test if the new owner can assign to a new address
     *
     * 2. an address that is not the owner will try to assign a new wallet address, expecting it to fail
     */
    function testFailNewOwnerAssignment() public {
        // assign new owner to the wallet contract
        wallet.setOwner(address(1));
        console.log("old owner address:", wallet.owner());

        // assign to a new address
        vm.prank(address(1));
        wallet.setOwner(address(2));
        console.log("new owner address", wallet.owner());

        // this is were the test should fail
        // bcs the test contract is no longer the owner
        // the owner is now address(2)
        wallet.setOwner(address(3));
    }
}
