// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Error} from "../src/Error.sol";

contract ErrorTestingAgain is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    function testFailCode() public view {
        err.throwError();
    }

    // here we are testing for the function to throw an error
    function testErrorCode() public {
        vm.expectRevert();
        err.throwError();
    }

    // we are testing the error msg
    function testCode() public {
        vm.expectRevert(bytes("not auth"));
        err.throwError();
    }

    // testing for custom errors
    function testCustomErr() public {
        vm.expectRevert(Error.NotAuth.selector);
        err.throwCustomError();
    }
}

contract ErrorTeste is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    // the function threw an error as expected
    function testFaile() public view {
        err.throwError();
    }

    function testThrowErrore() public {
        vm.expectRevert(bytes("not auth"));
        err.throwError();
    }

    function testCustomErrorFunc() public {
        vm.expectRevert(Error.NotAuth.selector);
        err.throwCustomError();
    }
}

contract ErrorTest is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    // check the code exe in a faild state
    function testFail() public view {
        err.throwError();
    }

    // how to test for failed code without defining Fail as part of the function name
    function testRevert() public {
        vm.expectRevert();
        err.throwError();
    }

    // how to test for error messages
    function testRequireMessage() public {
        vm.expectRevert(bytes("not auth"));
        err.throwError();
    }

    // how to test for custom error messages
    function testCustomError() public {
        vm.expectRevert(Error.NotAuth.selector);
        err.throwCustomError();
    }

    // how to label asserts | how to give custom names to assert checks
    function testErrorLabel() public pure {
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(2), "test 3");
        assertEq(uint256(1), uint256(1), "test 4");
    }
}
