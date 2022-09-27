// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ResultType, CallResult} from "src/result/CallResult.sol";

// -------------------------------------------------------------------------------------------------
// TYPE DECLARATIONS

type Contract is address;

// Converts (bool,bytes) to the `CallResult` type.
function toCallResult(bool success, bytes memory returnData) pure returns (CallResult res) {
    assembly {
        res := or(returnData, shl(248, success))
    }
}

// External contract call with Ether attached.
function callWithValue(Contract con, uint256 value, bytes memory callData) returns (CallResult cr) {
    assembly {
        // load free memory pointer
        // https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html
        let freememptr := mload(0x40)

        // CallResult cr = bool(success) | uint248(returndata pointer)
        cr := or(
            // success << 248
            shl(
                0xf8,
                call(gas(), con, value, add(0x20, callData), mload(callData), 0x00, 0x00)
            ),
            // returndata pointer
            freememptr
        )

        // returndata size
        let retsize := returndatasize()

        // store length of returndata at free memory pointer
        mstore(freememptr, retsize)

        // increment free memory pointer by 1 slot
        freememptr := add(freememptr, 0x20)

        // copy returndata at free memory pointer
        returndatacopy(freememptr, 0, retsize)

        // increment free memory pointer by returndata size, store at `0x40` per solidity standard.
        mstore(0x40, add(retsize, freememptr))
    }
}

// External contract call.
function call(Contract con, bytes memory callData) returns (CallResult cr) {
    assembly {
        // load free memory pointer
        // https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html
        let freememptr := mload(0x40)

        // CallResult cr = bool(success) | uint248(returndata pointer)
        cr := or(
            // success << 248
            shl(
                0xf8,
                call(gas(), con, 0, add(0x20, callData), mload(callData), 0x00, 0x00)
            ),
            // returndata pointer
            freememptr
        )

        // returndata size
        let retsize := returndatasize()

        // store length of returndata at free memory pointer
        mstore(freememptr, retsize)

        // increment free memory pointer by 1 slot
        freememptr := add(freememptr, 0x20)

        // copy returndata at free memory pointer
        returndatacopy(freememptr, 0, retsize)

        // increment free memory pointer by returndata size, store at `0x40` per solidity standard.
        mstore(0x40, add(retsize, freememptr))
    }
}

// External contract call with Ether attached.
function staticcall(Contract con, bytes memory callData) view returns (CallResult cr) {
    assembly {
        // load free memory pointer
        // https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html
        let freememptr := mload(0x40)

        // CallResult cr = bool(success) | uint248(returndata pointer)
        cr := or(
            // success << 248
            shl(
                0xf8,
                staticcall(gas(), con, add(0x20, callData), mload(callData), 0x00, 0x00)
            ),
            // returndata pointer
            freememptr
        )

        // returndata size
        let retsize := returndatasize()

        // store length of returndata at free memory pointer
        mstore(freememptr, retsize)

        // increment free memory pointer by 1 slot
        freememptr := add(freememptr, 0x20)

        // copy returndata at free memory pointer
        returndatacopy(freememptr, 0, retsize)

        // increment free memory pointer by returndata size, store at `0x40` per solidity standard.
        mstore(0x40, add(retsize, freememptr))
    }
}

// Unwraps the Contract type to address.
function asAddress(Contract con) pure returns (address a) {
    assembly {
        a := con
    }
}

// Returns the Ether balance of the Contract.
function etherBalance(Contract con) view returns (uint256 b) {
    assembly {
        b := balance(con)
    }
}

using {
    callWithValue,
    call,
    staticcall,
    asAddress,
    etherBalance
} for Contract global;
