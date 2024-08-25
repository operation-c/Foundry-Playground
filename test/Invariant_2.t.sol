// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {WETH} from "../src/WETH.sol";

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import "../src/IERC20Permit.sol";

// this contract is created to have granular control
// over the invariant testing

// invariant test: randomly calling functions expecting
// operation to work properly regardless of the sequence
contract Handler is CommonBase, StdCheats, StdUtils {
    WETH private weth;
    uint256 public wethBalance;

    constructor(WETH _weth) {
        weth = _weth;
    }

    receive() external payable {}

    function sendToFallBack(uint256 amount) public {
        // using address(this).balane -> this represents the balance of eth inside this contract 
        amount = bound(amount, 0, address(this).balance);

        wethBalance += amount;

        (bool ok, ) = address(weth).call{value: amount}("");
        if (!ok) { revert("tx failed"); }
    }

    function deposit(uint256 amount) public {
        // using address(this).balane -> this represents the balance of eth inside this contract 
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        weth.deposit{value: amount}();
    }

    function withdraw(uint256 amount) public {
        // using weth.balanceOf(address(this)) because it represents the amount of WETH that has been deposited into the WETH contract by the Handler contract.
        amount = bound(amount, 0, weth.balanceOf(address(this)));
        wethBalance -= amount;
        weth.withdraw(amount);
    }
}

contract WETH_Handler_Based_Invariant_Test is Test {
    WETH public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH();
        handler = new Handler(weth);

        deal(address(handler), 100 * 1e18);

        // directing foundry to only call functions inside the handler contract
        targetContract(address(handler));

        // we are now going to target a specific function 
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.sendToFallBack.selector;
        selectors[2] = Handler.withdraw.selector;
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
    }

    // testing to see the amount of eth inside the WETH contract is >= to the eth deposited from the handler contract 
    function invariant_ether_balance() public view {
        
        assertGe(address(weth).balance, handler.wethBalance());
        console.log("weth balance:", address(weth).balance);
    }
}


