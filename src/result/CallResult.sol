// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ResultType} from "src/result/Base.sol";

// aight hear me out.
// CallResult being a uint256 packs the call success boolean and a memory pointer into a single slot
// to be stored on the stack. Using the `status` and `data` "methods", we can access the "fields" of
// this virtual struct. We assume the memory pointer will not be greater than (2**248 - 1).

// -------------------------------------------------------------------------------------------------
// TYPE DECLARATIONS

// | success | memory pointer |
// | ------- | -------------- |
// | bool    | uint248        |
// | 8 bits  | 248 bits       |
type CallResult is uint256;

// -------------------------------------------------------------------------------------------------
// CONSTANT DECLARATIONS

// Mask for extracting the memory pointer
uint256 constant pointerMask = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

// Error to bubble up revert data.
error CallRevert(bytes revertData);

// Error to revert with custom message.
error CallRevertWithMessage(string message);

// -------------------------------------------------------------------------------------------------
// FUNCTION DECLARATIONS

// Gets the `ReturnType` status of the call result.
function status(CallResult res) pure returns (ResultType typ) {
    assembly {
        typ := shr(248, res)
    }
}

// Gets the returndata bytes by extracting the memory pointer.
// WARNING: This abuses assembly's ability to bypass type checks.
function data(CallResult res) pure returns (bytes memory ret) {
    assembly {
        ret := and(pointerMask, res)
    }
}

// Returns true if `ReturnType` status is `Ok`.
function isOk(CallResult res) pure returns (bool) {
    return res.status() == ResultType.Ok;
}

// Returns true if `ReturnType` status is `Err`.
function isErr(CallResult res) pure returns (bool) {
    return res.status() == ResultType.Err;
}

// Either returns the call's returndata bytes OR reverts, bubbling up the revert data. 
function unwrap(CallResult res) pure returns (bytes memory) {
    if (res.isErr()) revert CallRevert(res.data());

    return res.data();
}

// Either returns the call's returndata bytes OR reverts with a custom revert string.
function expect(CallResult res, string memory revertMessage) pure returns (bytes memory) {
    if (res.isErr()) revert CallRevertWithMessage(revertMessage);

    return res.data();
}

using { status, data, isOk, isErr, unwrap, expect } for CallResult global;
