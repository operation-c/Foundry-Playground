// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Error {
    error NotAuth();

    function throwError() external pure {
        require(false, "not auth");
    }

    function throwCustomError() external pure {
        revert NotAuth();
    }
}
