// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract SignTeter is Test {
    function testValidation() public pure {
        uint256 privateKey = 123;

        address publicAddress = vm.addr(privateKey);

        bytes32 messageHash = keccak256("secret message");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        address signer = ecrecover(messageHash, v, r, s);

        assertEq(signer, publicAddress);
    }
}

contract SignTest is Test {
    function testSignature() public pure {
        uint256 privateKey = 123;
        address pubKey = vm.addr(privateKey);
        bytes32 messageHash = keccak256("Secret message");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        address signer = ecrecover(messageHash, v, r, s);

        assertEq(signer, pubKey);
    }
}
